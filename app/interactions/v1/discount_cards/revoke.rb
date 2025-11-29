# frozen_string_literal: true

module V1
  module DiscountCards
    class Revoke < ApplicationInteraction
      array :restaurant_ids do
        integer
      end
      array :network_guest_ids, :discount_card_ids do
        integer
      end

      def execute
        restaurant_ids.each do |restaurant_id|
          network_guest_ids.each do |network_guest_id|
            discount_card_ids.each do |discount_card_id|
              network_guest_discount_card = NetworkGuestDiscountCard.find_by(network_guest_id:, discount_card_id:, restaurant_id:)
              next unless network_guest_discount_card

              send_mail(network_guest_id, discount_card_id) if network_guest_discount_card.active? && network_guest_discount_card.revoked!
              network_guest_discount_card&.logs&.first&.update(meta_data: { action: 'revoke' })
            end
          end
        end
      end

      def to_model
        { message: 'Discount Card revoked successfully' }
      end

      private

      # Uncomment the below lines when mail needs to be sent upon assigning or revoking a discount card.
      def send_mail(_network_guest_id, discount_card_id)
        # network_guest = NetworkGuest.find(network_guest_id)
        discount_card = DiscountCard.find(discount_card_id)
        check_active_network_guests(discount_card)
        # NetworkGuestMailer.discount_card_revoke_email(network_guest, discount_card).deliver_later
      end

      def check_active_network_guests(discount_card)
        card = NetworkGuestDiscountCard.where(discount_card_id: discount_card.id, status: 'active')
        return if card.present?

        discount_card.inactive!
      end
    end
  end
end
