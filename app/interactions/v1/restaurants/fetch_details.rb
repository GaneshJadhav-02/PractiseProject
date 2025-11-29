# frozen_string_literal: true

module V1
  module Restaurants
    class FetchDetails < ApplicationInteraction
      boolean :is_fetch
      string :toast_client_id, :toast_client_secret_key, :toast_user_access_type, :toast_restaurant_external_id, :toast_url
      validates :toast_client_id, :toast_client_secret_key, :toast_user_access_type, :toast_restaurant_external_id, :toast_url, presence: true

      validate do
        encrypt_id = EncryptionService.encrypt(toast_restaurant_external_id)
        @restaurant = Restaurant.find_by(toast_restaurant_external_id: encrypt_id)
        errors.add(:restaurant_external_id, :exists) if is_fetch && @restaurant.present?
      end

      def execute
        @detail = ::Toast::Api::RestaurantDetail.call(form_restaurant)
        if @detail[:error].present?
          errors.add(:error, @detail[:error])
        elsif @restaurant.present?
          check_restaurant_timezone
        end
      end

      def to_model
        @detail
      end

      private

      def form_restaurant
        {
          toast_url: toast_url,
          toast_client_id: toast_client_id,
          toast_client_secret_key: toast_client_secret_key,
          toast_user_access_type: toast_user_access_type,
          toast_restaurant_external_id: toast_restaurant_external_id
        }
      end

      def check_restaurant_timezone
        timezone_from_toast = @detail[:restaurant_data]&.dig('general', 'timeZone')
        return if timezone_from_toast.blank?

        return unless @restaurant.time_zone.blank? || @restaurant.time_zone != timezone_from_toast

        transactional_update!(@restaurant, { time_zone: timezone_from_toast })
        reschedule_sidekiq_jobs
      end

      def reschedule_sidekiq_jobs
        ::Restaurant::TOAST_IMPORT_WORKERS.each do |worker_name|
          Sidekiq::ScheduledSet.new.select do |job|
            job.klass == worker_name.to_s && job.args[0] == @restaurant.id
          end.each do |job|
            time = job.klass == 'Toast::ImportEmployeeWorker' ? '4:40 AM' : '4:30 AM'
            scheduling_time = time.in_time_zone(@restaurant.time_zone)

            job.reschedule(scheduling_time)
          end
        end
      end
    end
  end
end
