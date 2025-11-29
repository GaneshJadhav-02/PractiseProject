# frozen_string_literal: true

module Toast
  class ImportJobWorker
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
        module_name: 'job'
      ) do
        jobs = ::Toast::Api::ImportJob.call(restaurant)
        if jobs.is_a?(Hash) && jobs[:error].present?
          job_status = 'failed'
          raise StandardError, "ImportJob worker failed: #{jobs[:error]}"
        end
        job_status = 'success'
      rescue StandardError
        job_status = 'failed'
        raise
      ensure
        Toast::ImportJobWorker.fetch_report(restaurant_id) if job_status == 'success' || JobUtil.last_retry_attempt?
      end
    end

    def self.fetch_report(restaurant_id)
      period = ((Date.current + 1.day).end_of_day - 10.minute)
      perform_at(period, restaurant_id)
    end
  end
end
