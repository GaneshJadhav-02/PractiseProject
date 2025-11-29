# frozen_string_literal: true

module V1
  module DiscountCards
    class Base < ApplicationInteraction
      string :background_image, default: nil
      boolean :delete_background_image, default: false

      private

      def validate_color
        pattern = /^#[A-Fa-f0-9]{6}$/
        errors.add(:color, :invalid) unless color.match?(pattern)
      end

      def validate_network_guest_ids
        errors.add(:base, :not_unique, attribute: NetworkGuest.name) unless network_guest_ids.length == network_guest_ids.uniq.length
        errors.add(:base, :invalid, attribute: NetworkGuest.name) unless (network_guest_ids - NetworkGuest.ids).empty?
      end

      def validate_discount_card_ids
        errors.add(:base, :not_unique, attribute: DiscountCard.name) unless discount_card_ids.length == discount_card_ids.uniq.length
        errors.add(:base, :invalid, attribute: DiscountCard.name) unless (discount_card_ids - DiscountCard.ids).empty?
      end

      def validate_categories_arrays
        categories.each do |rule|
          errors.add(:categories, :category) if rule[:category].blank?
        end
      end

      def add_error(key)
        errors.add(key, 'Some fields are empty')
      end

      def attach_background_image(discount_card)
        return unless inputs[:background_image].present?

        if delete_background_image
          discount_card.background_image.purge
          return
        end

        transactional_update!(discount_card, { background_image: { data: inputs[:background_image] } })
      end
    end
  end
end
