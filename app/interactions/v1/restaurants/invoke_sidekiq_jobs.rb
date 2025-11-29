# frozen_string_literal: true

module V1
  module Restaurants
    class InvokeSidekiqJobs < Base
      # object :restaurant, class: Restaurant

      validate :validate_toast_credentials

      def execute
        ::Restaurant::TOAST_IMPORT_WORKERS.each do |worker|
          worker.fetch_report(restaurant.id) unless SidekiqJobsTracker.call(restaurant.id, worker).present?
        end
      end

      def to_model
        {
          message: 'Jobs invoked successfully'
        }
      end

      private

      def validate_toast_credentials
        toast_credentials = %w[toast_url toast_client_id toast_client_secret_key toast_user_access_type toast_restaurant_external_id]
        missing_credentials = toast_credentials.select { |credential| restaurant[credential].blank? }

        if missing_credentials.any?
          errors.add(:base, 'Unable to invoke jobs due to missing toast credentials.')
        else
          res = Toast::Api::RestaurantDetail.call(toast_credentials_of_restaurant)
          errors.add(:base, :invalid_toast_credentials) if res[:error].present?
        end
        throw(:abort)
      end

      def toast_credentials_of_restaurant
        {
          toast_url: restaurant.toast_url,
          toast_client_id: EncryptionService.decrypt(restaurant.toast_client_id),
          toast_client_secret_key: EncryptionService.decrypt(restaurant.toast_client_secret_key),
          toast_user_access_type: EncryptionService.decrypt(restaurant.toast_user_access_type),
          toast_restaurant_external_id: EncryptionService.decrypt(restaurant.toast_restaurant_external_id)
        }
      end
    end
  end
end
