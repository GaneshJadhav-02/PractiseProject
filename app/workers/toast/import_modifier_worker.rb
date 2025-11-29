# frozen_string_literal: true

module Toast
  class ImportModifierWorker
    require 'sidekiq/api'
    include Sidekiq::Worker

    def perform(restaurant_id)
      restaurant = Restaurant.find_by_id(restaurant_id)
      return if restaurant.nil?

      job_status = nil
      start_date = "#{Time.current.beginning_of_day.iso8601.chop}.000Z"
      end_date = "#{(Time.current.beginning_of_day + 1.day).iso8601.chop}.000Z"
      JobLogger.log(
        worker: self,
        job_id: jid,
        restaurant_id: restaurant_id,
        module_name: 'modifier'
      ) do
        modifiers = ::Toast::Api::ImportModifier.call(restaurant, start_date, end_date)
        if modifiers.is_a?(Hash) && modifiers[:error].present?
          job_status = 'failed'
          raise StandardError, "ImportModifier worker failed: #{modifiers[:error]}"
        end
        job_status = 'success'
      rescue StandardError
        job_status = 'failed'
        raise
      ensure
        Toast::ImportModifierWorker.fetch_report(restaurant_id) if job_status == 'success' || JobUtil.last_retry_attempt?
      end
    end

    def self.fetch_report(restaurant_id)
      period = ((Date.current + 1.day).end_of_day - 5.minute)
      perform_at(period, restaurant_id)
    end
  end
end
