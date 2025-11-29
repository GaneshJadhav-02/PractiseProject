# frozen_string_literal: true

module Toast
  class ImportEmployeeWorker
    require 'sidekiq/api'
    include Sidekiq::Worker

    def perform(restaurant_id)
      restaurant = Restaurant.find_by_id(restaurant_id)
      return if restaurant.nil?

      job_status = nil

      JobLogger.log(
        worker: self,
        job_id: jid,
        restaurant_id: restaurant_id,
        module_name: 'employee'
      ) do
        employees = ::Toast::Api::EmployeeImporter.call(restaurant)
        if employees.is_a?(Hash) && employees[:error].present?
          job_status = 'failed'
          raise StandardError, "ImportEmployee worker failed: #{employees[:error]}"
        end
        job_status = 'success'
      rescue StandardError
        job_status = 'failed'
        raise
      ensure
        Toast::ImportEmployeeWorker.fetch_report(restaurant_id) if job_status == 'success' || JobUtil.last_retry_attempt?
      end
    end

    def self.fetch_report(restaurant_id)
      period = ((Date.current + 1.day).end_of_day - 5.minute)
      perform_at(period, restaurant_id)
    end
  end
end
