# frozen_string_literal: true

module Api
  class OrdersQuery < ApplicationQuery
    # rubocop:disable Metrics/MethodLength
    def call
      restaurant_group_id = options[:restaurant_group_id]
      restaurant_ids = options[:restaurant_ids] || []
      network_guest_name = options[:network_guest_name]
      date_range, time_range = options[:date_range], options[:time_range]
      dining_options = options[:dining_options]
      discounted = options[:discounted]
      revenue_center = options[:revenue_center]
      service, voided = options[:service], options[:voided]
      tax_exempted = options[:tax_exempted]
      order_source = options[:order_source]
      dining_area = options[:service_area]
      opened = options[:opened] || false
      closed = options[:closed] || false
      paid = options[:paid] || false
      has_ot_discount = options[:has_ot_discount] || false

      scope = ::Order.all
      scope = load_restaurant_permitted_data(scope)
      if restaurant_group_id.present? && restaurant_ids.empty?
        restaurant_group = RestaurantGroup.find(restaurant_group_id)
        restaurant_ids = restaurant_group.restaurants.pluck(:id) if restaurant_group.present?
      end
      scope = scope.where(restaurant_id: restaurant_ids) if restaurant_ids.present?
      scope = scope.where(dining_options:) if dining_options.present?
      scope = filter_discounted(scope, discounted)
      scope = scope.where(revenue_center:) if revenue_center.present?
      scope = scope.where(service:) if service.present?
      scope = scope.where(voided: ActiveModel::Type::Boolean.new.cast(voided)) if voided.present?
      scope = scope.where.not(opened: nil) if opened
      scope = scope.where.not(closed: nil) if closed
      scope = scope.where.not(paid: nil) if paid
      scope = scope.where(dining_area:) if dining_area.present?
      scope = filter_tax_exempted(scope, tax_exempted) if tax_exempted.present?
      scope = scope.where(order_source:) if order_source.present?
      scope = scope.where(has_ot_discount:) if has_ot_discount
      scope = search_by_range(scope, date_range, time_range)
      if network_guest_name.present?
        scope = scope.joins(:network_guest)
                      .where("CONCAT(network_guests.first_name, ' ', network_guests.last_name) ILIKE ?", "%#{network_guest_name}%")
      end

      scope&.order('created_at asc')
    end
    # rubocop:enable Metrics/MethodLength

    private

    def search_by_date_range(scope, range)
      from = if range[:from].blank?
                1000.year.ago.to_date.beginning_of_day + 6.hours
              else
                range[:from].to_date.beginning_of_day + 6.hours
              end
      to = if range[:to].blank?
              DateTime::Infinity.new
            else
              range[:to].to_date.end_of_day + 6.hours
            end
      scope.where(opened: from..to)
    end

    def search_by_range_time(scope, range)
      from = (Time.strptime(range[:from], '%H:%M') + 6.hours).strftime('%H:%M')
      to = if range[:to].blank?
              (Time.current + 6.hours).strftime('%H:%M')
            else
              (Time.strptime(range[:to], '%H:%M') + 6.hours).strftime('%H:%M')
            end
      scope.where('opened::time BETWEEN ? AND ?', from, to)
    end

    def search_by_range(scope, date_range, time_range)
      scope = search_by_date_range(scope, date_range) if date_range.present?
      scope = search_by_range_time(scope, time_range) if time_range.present?
      scope
    end

    def filter_discounted(scope, discounted)
      return scope unless discounted.present?

      if discounted == 'true'
        scope.where('discount_amount >= ?', '0.000')
      else
        scope.where('discount_amount < ?', '1')
      end
    end

    def filter_tax_exempted(scope, tax_exempted)
      if tax_exempted == 'true'
        scope.where('tax <= ?', '0.00')
      else
        scope.where('tax > ?', '0.00')
      end
    end
  end
end
