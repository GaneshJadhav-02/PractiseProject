# frozen_string_literal: true

module RoundDecimalValues
  extend ActiveSupport::Concern

  included do
    def attributes(*args)
      deep_round(super)
    end

    def round_string_decimals(data, *attribute_names)
      attribute_names.each do |attr|
        value = begin
          object.public_send(attr)
        rescue StandardError
          nil
        end
        next unless value.present?

        if value.is_a?(String) && value.match?(/\A-?\d+(\.\d+)?\z/)
          rounded_value = format('%.2f', value.to_f.round(2))
          data[attr] = rounded_value
        end
      end
    end

    private

    def deep_round(obj)
      case obj
      when Hash
        obj.transform_values { |v| deep_round(v) }
      when Array
        obj.map { |v| deep_round(v) }
      when BigDecimal, Float
        obj.to_f.round(2)
      else
        obj
      end
    end
  end
end
