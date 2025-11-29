# frozen_string_literal: true

module V1
  module Restaurants
    class CheckIn < ApplicationInteraction
      string :restaurant_id
      integer :network_guest_id
      string :discount_card_id
      string :code
      string :date

      validate do
        @guest_card = NetworkGuestDiscountCard.find(discount_card_id)
      end

      def execute
        ActiveRecord::Base.transaction do
          check_in = transactional_create!(::DiscountCheckIn, check_in_params)
          @discount_code = check_in.discount_code

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        { code: @discount_code }
      end

      private

      def check_in_params
        {
          discount_code: code,
          network_guest_id:,
          check_in: date,
          restaurant_id:,
          discount_card_id: @guest_card.discount_card_id,
          visitor_restaurant_id: @guest_card.restaurant&.id
        }
      end
    end
  end
end
