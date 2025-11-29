# frozen_string_literal: true

module V1
  module Restaurants
    class Update < Base
      # object :restaurant, class: Restaurant
      with_options default: nil do |attr|
        attr.string :name
        attr.string :phone
        attr.string :phone_country_code
        attr.string :website
        attr.integer :cuisine_id
        attr.string :description
        attr.string :amount_per_guest
        attr.file :cropped_profile_photo
        attr.file :display_profile_photo
        attr.integer :restaurant_group_id
        attr.string :toast_email
        attr.string :toast_password
        attr.string :toast_authenticator_key
        attr.string :toast_client_id
        attr.string :toast_client_secret_key
        attr.string :toast_user_access_type
        attr.string :toast_restaurant_external_id
        attr.string :toast_url
        attr.decimal :addr_lat
        attr.decimal :addr_lng
        attr.string :addr_street
        attr.string :addr_city
        attr.string :addr_state
        attr.string :addr_code
        attr.string :addr_country
        attr.string :address
        attr.string :background_color
        attr.string :category
      end

      validate :unique_business_days,
               :unique_categories_per_day, if: :business_days

      validate :check_restaurant, :validate_tip_compliance_threshold

      validate do
        RestaurantGroup.find(restaurant_group_id) unless restaurant_group_id.nil?
      end

      validates :name, presence: true, if: :name
      validates :phone, presence: true, if: :phone
      validates :restaurant_group_id, presence: true, if: :restaurant_group_id

      def execute
        ActiveRecord::Base.transaction do
          all_params = restaurant_params.merge(toast_params)
          transactional_update!(restaurant, all_params)
          attach_profile_photo(restaurant)
          attach_thumbnail(restaurant)
          if business_days.present?
            restaurant.business_hours.destroy_all
            save_business_days(restaurant)
          end
          raise ActiveRecord::Rollback if errors.any?
        end
        self
      end

      def to_model
        restaurant.reload
      end

      private

      def restaurant_params
        inputs.excluding(encrypted_toast_keys + %i[restaurant business_days profile_photo thumbnail]).compact_blank
      end

      def toast_params
        params = {}
        encrypted_toast_keys.each do |key|
          value = inputs[key]

          params[key] = if encrypted_toast_keys.excluding(:toast_url).include?(key) && value.present?
                          EncryptionService.encrypt(value)
                        else
                          value
                        end
        end
        params
      end

      def encrypted_toast_keys
        %i[
          toast_password
          toast_authenticator_key
          toast_client_id
          toast_client_secret_key
          toast_user_access_type
          toast_restaurant_external_id
          toast_url
        ]
      end

      def check_restaurant
        return unless toast_restaurant_external_id.present?

        encrypt_id = EncryptionService.encrypt(toast_restaurant_external_id)
        restaurant_external_id = Restaurant.find_by(toast_restaurant_external_id: encrypt_id)
        return if restaurant_external_id.nil? || restaurant.id == restaurant_external_id&.id

        errors.add(:restaurant_external_id, :exists)
      end
    end
  end
end
