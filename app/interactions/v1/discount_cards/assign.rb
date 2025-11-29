# frozen_string_literal: true

module V1
  module DiscountCards
    class Assign < Base
      array :restaurant_ids do
        integer
      end
      array :discount_card_ids, :network_guest_ids do
        integer
      end

      validate :validate_discount_card_ids
      validate :validate_network_guest_ids, if: -> { network_guest_ids }

      def execute
        ActiveRecord::Base.transaction do
          restaurant_ids.each do |restaurant_id|
            discount_card_ids.each do |id|
              discount_card = DiscountCard.find(id)

              create_network_guest_discount_card_records(discount_card, network_guest_ids, restaurant_id) if network_guest_ids

              discount_card.active!
            end
          end

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        { message: 'Discount Cards assigned successfully' }
      end

      private

      def create_network_guest_discount_card_records(discount_card, network_guest_ids, restaurant_id)
        network_guest_ids.each do |id|
          network_guest = NetworkGuest.find(id)

          next unless network_guest&.active_restaurants&.pluck(:id)&.include?(restaurant_id)

          if NetworkGuestDiscountCard.exists?(network_guest:, discount_card:, restaurant_id:)
            record = NetworkGuestDiscountCard.find_by(network_guest:, discount_card:, restaurant_id:)
            send_mail(network_guest, discount_card) if record.revoked? && record.active!
            record&.logs&.first&.update(meta_data: { action: 'assign' })
            next
          end

          network_guest_discount_card = transactional_create!(
            NetworkGuestDiscountCard,
            { network_guest:, discount_card:, restaurant_id: }
          )
          send_mail(network_guest, discount_card) if network_guest_discount_card.present?
          network_guest_discount_card&.logs&.first.update(meta_data: { action: 'assign' })
        end
      end

      # Uncomment the below line when mail needs to be sent upon assigning or revoking a discount card.
      def send_mail(network_guest, discount_card)
        # NetworkGuestMailer.discount_card_assignment_email(network_guest, discount_card).deliver_later
      end
    end
  end
end
