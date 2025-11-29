# frozen_string_literal: true

module V1
  module Restaurants
    class Favourite < ApplicationInteraction
      # object :restaurant, class: ::Restaurant
      # object :network_guest, class: ::NetworkGuest

      def execute
        ActiveRecord::Base.transaction do
          favourite = network_guest.favourite_restaurants.find_by(restaurant:)
          if favourite
            favourite.destroy
          else
            transactional_create!(network_guest.favourite_restaurants, { restaurant: })
          end

          raise ActiveRecord::Rollback if errors.any?
        end
      end
    end
  end
end
