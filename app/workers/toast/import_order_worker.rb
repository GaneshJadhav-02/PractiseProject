# frozen_string_literal: true

module Toast
  class ImportOrderWorker
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
        module_name: 'order'
      ) do
        orders = ::Toast::Api::ImportOrder.call(restaurant, start_date, end_date)
        if orders.is_a?(Hash) && orders[:error].present?
          job_status = 'failed'
          raise StandardError, "ImportOrder worker failed: #{orders[:error]}"
        end
        job_status = 'success'
      rescue StandardError
        job_status = 'failed'
        raise
      ensure
        Toast::ImportOrderWorker.fetch_report(restaurant_id) if job_status == 'success' || JobUtil.last_retry_attempt?
      end
    end

    def self.fetch_report(restaurant_id)
      period = ((Date.current + 1.day).end_of_day - 10.minute)
      perform_at(period, restaurant_id)
    end
  end
end
