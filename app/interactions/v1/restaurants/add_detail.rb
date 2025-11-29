# frozen_string_literal: true

module V1
  module Restaurants
    class AddDetail < ApplicationInteraction
      # object :restaurant, class: Restaurant
      with_options default: nil do |attr|
        attr.string :caterings
        attr.string :cross_street
        attr.string :delivery_options
        attr.string :delivery_url
        attr.string :dress_code
        attr.string :executive_chef
        attr.string :menu_url
        attr.string :parking
        attr.string :private_events
        attr.string :public_transit_stops
        attr.string :restaurant_type
        attr.string :amenities
        attr.string :accessibility
        attr.string :payment_options
        attr.string :beverages
        attr.string :dietary_options
        attr.string :smoking
      end
      with_options default: [] do |attr|
        attr.array :cleaning_and_sanitizing
        attr.array :diversity
        attr.array :physical_distancing
        attr.array :protective_equipment
        attr.array :screening
      end

      def execute
        ActiveRecord::Base.transaction do
          @restaurant_detail = if restaurant.restaurant_detail.present?
                                 transactional_update!(
                                   restaurant&.restaurant_detail,
                                   inputs&.except(:restaurant)&.compact_blank
                                 )
                               else
                                 transactional_create!(RestaurantDetail, inputs)
                               end
          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        @restaurant_detail
      end
    end
  end
end
