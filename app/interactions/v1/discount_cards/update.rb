# frozen_string_literal: true

module V1
  module DiscountCards
    class Update < Base
      # object :discount_card, class: ::DiscountCard
      string :name, :color, default: nil

      string :exclusions, default: nil

      array :categories, default: nil do
        hash do
          integer :id, default: nil
          string :category, default: nil
          string :number_of_guests, default: nil
          string :discount, default: nil
          string :applies_to, default: nil
        end
      end

      validates :name, presence: true, if: :name
      validates :categories, presence: true, if: :categories

      validate :validate_categories_arrays, if: -> { categories }
      validate :validate_color, if: -> { color }

      def execute
        ActiveRecord::Base.transaction do
          transactional_update!(discount_card, discount_card_params)
          update_categories if categories
          attach_background_image(discount_card)

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        discount_card.reload
      end

      private

      def discount_card_params
        inputs.except(:discount_card, :categories, :background_image, :delete_background_image).compact
      end

      def update_categories
        rule_ids = categories.pluck(:id)
        discount_card.rules.where.not(id: rule_ids).destroy_all

        categories.each do |rule|
          if rule[:id].nil?
            discount_card.rules.create(rule.compact)
          else
            discount_card_rule = discount_card.rules.find(rule[:id])

            rule.compact.except(:id).each do |key, value|
              discount_card_rule[key] = value
            end

            discount_card_rule.save
          end
        end
      end
    end
  end
end
