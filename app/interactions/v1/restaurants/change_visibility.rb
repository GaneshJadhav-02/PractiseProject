# frozen_string_literal: true

module V1
  module Restaurants
    class ChangeVisibility < ApplicationInteraction
      # object :restaurant, class: Restaurant
      boolean :is_visible

      def execute
        ActiveRecord::Base.transaction do
          transactional_update!(restaurant, visibility_params)

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        restaurant.reload
      end

      private

      def visibility_params
        {
          entity_type: is_visible ? 'restaurant' : 'back_office'
        }
      end
    end
  end
end
