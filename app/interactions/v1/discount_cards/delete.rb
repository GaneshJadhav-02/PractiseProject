# frozen_string_literal: true

module V1
  module DiscountCards
    class Delete < ApplicationInteraction
      # object :object, class: ::DiscountCard

      validate :validate_not_active

      def execute
        object.destroy
      end

      def to_model
        object
      end

      private

      def validate_not_active
        errors.add(:base, :invalid) if object.active?
      end
    end
  end
end
