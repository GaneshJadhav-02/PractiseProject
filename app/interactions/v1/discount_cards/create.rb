# frozen_string_literal: true

module V1
  module DiscountCards
    class Create < Base
      string :name, :color
      integer :restaurant_group_id
      array :categories do
        hash do
          string :category
          string :number_of_guests
          string :discount
          string :applies_to
        end
      end
      string :exclusions, default: nil

      validates :name, :color, presence: true

      validate :validate_categories_arrays, :validate_color

      validate do
        errors.add(:restaurant_group, :not_found) unless RestaurantGroup.exists?(id: restaurant_group_id)
      end

      def execute
        ActiveRecord::Base.transaction do
          @discount_card = transactional_create!(DiscountCard, discount_card_params)
          categories.each do |category|
            category.merge!(discount_card_id: @discount_card.id)
            transactional_create!(DiscountCardRule, category)
          end
          attach_background_image(@discount_card)

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        @discount_card.reload
      end

      private

      def discount_card_params
        inputs.except(:categories, :background_image, :delete_background_image).compact
      end
    end
  end
end
