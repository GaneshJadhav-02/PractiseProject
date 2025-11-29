# frozen_string_literal: true

module V1
  module Restaurants
    class Base < ApplicationInteraction
      string :profile_photo, default: nil
      string :time_zone, default: nil
      string :thumbnail, default: nil
      integer :additional_cuisine_one_id, default: nil
      integer :additional_cuisine_two_id, default: nil
      array :business_days, default: [] do
        hash do
          string :day
          array :hours, default: [] do
            hash do
              string :category
              time :open_time
              time :close_time
            end
          end
        end
      end
      array :images, default: []
      float :tip_compliance_threshold, default: nil

      def attach_profile_photo(restaurant)
        return unless inputs[:profile_photo].present?

        transactional_update!(restaurant, profile_photo_params)
      end

      def attach_thumbnail(restaurant)
        return unless inputs[:thumbnail].present?

        transactional_update!(restaurant, { thumbnail: { data: inputs[:thumbnail] } })
      end

      def attach_gallery_images(restaurant)
        return unless inputs[:images].present?

        images.each do |img|
          transactional_create!(Image, { file: img, display_image: img, restaurant: })
        end
      end

      def unique_business_days
        day_names = business_days.map { |bd| bd[:day] }
        return if day_names.uniq.length == day_names.length

        errors.add(:business_days, :duplicate_days)
        throw(:abort)
      end

      def unique_categories_per_day
        business_days.each do |business_day|
          category_names = business_day[:hours].map { |hour| hour[:category] }
          next if category_names.uniq.length == category_names.length

          errors.add(:business_days, :duplicate_categories, attribute: business_day[:day])
          throw(:abort)
        end
      end

      def save_business_days(restaurant)
        business_days.each do |business_day|
          day_record = BusinessDay.find_or_create_by!(name: business_day[:day])

          business_day[:hours].each do |hour|
            BusinessHour.create!(restaurant:,
                                 business_day: day_record,
                                 category: hour[:category],
                                 open_time: hour[:open_time],
                                 close_time: hour[:close_time])
          end
        end
      end

      def number_of_images
        return if images.size <= 50

        errors.add(:images, :max_images_limit)
        throw(:abort)
      end

      def validate_image_size
        images.each do |img|
          next if img.size <= 12.megabytes

          errors.add(:images, :invalid_size, attribute: img&.original_filename)
          throw(:abort)
        end
      end

      def validate_image_type
        images.each do |img|
          file_type = img&.path
                         &.split('.')
                         &.last
                         &.downcase
          next if %w[jpeg jpg png].include? file_type

          errors.add(:images, :invalid_type, attribute: img&.original_filename)
          throw(:abort)
        end
      end

      def profile_photo_params
        {
          display_profile_photo: { data: inputs[:profile_photo] },
          cropped_profile_photo: { data: inputs[:profile_photo] },
          profile_photo: { data: inputs[:profile_photo] }
        }
      end

      def validate_tip_compliance_threshold
        return unless inputs[:tip_compliance_threshold].present?

        errors.add(:tip_compliance_threshold, :invalid_value) unless tip_compliance_threshold.between?(1, 100)
        throw(:abort)
      end
    end
  end
end
