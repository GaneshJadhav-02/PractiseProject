# frozen_string_literal: true

module V1
  module Restaurants
    class Create < Base
      string :name
      string :phone
      string :phone_country_code, default: nil
      string :website, default: nil
      integer :cuisine_id, default: nil
      string :description, default: nil
      string :amount_per_guest, default: nil
      integer :restaurant_group_id, default: nil
      string :toast_email, default: nil
      string :toast_password, default: nil
      string :toast_authenticator_key, default: nil
      string :toast_url, default: nil
      string :toast_client_id, default: nil
      string :toast_client_secret_key, default: nil
      string :toast_user_access_type, default: nil
      string :toast_restaurant_external_id, default: nil
      decimal :addr_lat, default: nil
      decimal :addr_lng, default: nil
      string :addr_street, default: nil
      string :addr_city, default: nil
      string :addr_state, default: nil
      string :addr_code, default: nil
      string :addr_country, default: nil
      string :address, default: nil
      string :background_color, default: nil
      string :category, default: nil
      string :payment_options, default: nil
      string :parking, default: nil
      string :dress_code, default: nil
      string :accessibility, default: nil
      string :menu_url, default: nil

      validates :name, :phone, presence: true

      validate :unique_business_days,
               :unique_categories_per_day, if: -> { business_days.present? }
      validate :check_restaurant, :validate_tip_compliance_threshold
      validate :number_of_images,
               :validate_image_type,
               :validate_image_size, if: -> { images.present? }

      def execute
        ActiveRecord::Base.transaction do
          @restaurant = transactional_create!(Restaurant, restaurant_params)
          attach_profile_photo(@restaurant)
          attach_thumbnail(@restaurant)
          save_business_days(@restaurant)
          save_additional_details
          attach_gallery_images(@restaurant)

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        @restaurant
      end

      private

      def restaurant_params
        params = inputs.slice(:name, :phone, :website,
                              :cuisine_id, :additional_cuisine_one_id,
                              :additional_cuisine_two_id,
                              :amount_per_guest,
                              :description,
                              :restaurant_group_id,
                              :time_zone,
                              :tip_compliance_threshold,
                              :toast_email,
                              :toast_url, :addr_lat, :addr_lng, :addr_street,
                              :addr_city, :addr_state, :addr_code,
                              :addr_country, :address, :background_color,
                              :category, :phone_country_code)
        params[:toast_password] = EncryptionService.encrypt(toast_password) if toast_password.present?
        params[:toast_authenticator_key] = EncryptionService.encrypt(toast_authenticator_key) if toast_authenticator_key.present?
        params[:toast_client_id] = EncryptionService.encrypt(toast_client_id) if toast_client_id.present?
        params[:toast_client_secret_key] = EncryptionService.encrypt(toast_client_secret_key) if toast_client_secret_key.present?
        params[:toast_user_access_type] = EncryptionService.encrypt(toast_user_access_type) if toast_user_access_type.present?
        params[:toast_restaurant_external_id] = EncryptionService.encrypt(toast_restaurant_external_id) if toast_restaurant_external_id.present?
        params
      end

      def check_restaurant
        return unless toast_restaurant_external_id.present?

        encrypt_id = EncryptionService.encrypt(toast_restaurant_external_id)
        restaurant_external_id = Restaurant.find_by(toast_restaurant_external_id: encrypt_id)
        errors.add(:restaurant_external_id, :exists) unless restaurant_external_id.nil?
      end

      def save_additional_details
        additional_params = inputs.slice(:payment_options,
                                         :parking,
                                         :dress_code,
                                         :accessibility,
                                         :menu_url).merge(restaurant: @restaurant).compact_blank

        transactional_create!(RestaurantDetail, additional_params)
      end
    end
  end
end
