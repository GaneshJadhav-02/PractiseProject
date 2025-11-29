# frozen_string_literal: true

module V1
  module Restaurants
    class RevokeSidekiqJobs < Base
      # object :restaurant, class: Restaurant

      def execute
        ::Restaurant::TOAST_IMPORT_WORKERS.each do |worker|
          SidekiqJobsTracker.call(restaurant.id, worker).each(&:delete)
        end
      end

      def to_model
        {
          message: 'Jobs revoked successfully'
        }
      end
    end
  end
end
