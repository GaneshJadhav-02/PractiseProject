# frozen_string_literal: true

module Api
  class DiscountCheckInSerializer < ::Api::ApplicationSerializer
    include RoundDecimalValues

    attributes :id,
               :discount_code,
               :check_in,
               :total_discount,
               :order,
               :visiting_restaurant,
               :network_guest,
               :visitor_restaurant,
               :time_zone_abbr

    def order
      data = object&.order
      return nil if data.nil?

      {
        id: data.id,
        order_id: data.order_id,
        total: format('%.2f', data.total.to_f.round(2)),
        opened: data.restaurant&.restaurant_time_zone(data.opened) || central_time_zone(data.opened),
        order_no: data&.order_no
      }
    end

    def visiting_restaurant
      object&.restaurant&.as_json(only: %i[id name])
    end

    def network_guest
      object&.network_guest&.as_json(only: %i[id phone_number network_guest_id first_name last_name])
    end

    def visitor_restaurant
      object&.visitor_restaurant&.as_json(only: %i[id name])
    end

    def time_zone_abbr
      object&.order&.restaurant&.time_zone_abbrevation || 'CDT'
    end

    def total_discount
      object.update(total_discount: object.order.discount_amount) if object.order.present? && object.total_discount.to_s != object.order.discount_amount
      object.total_discount
    end
  end
end
