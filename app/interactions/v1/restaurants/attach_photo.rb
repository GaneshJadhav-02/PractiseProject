# frozen_string_literal: true

module V1
  module Restaurants
    class AttachPhoto < ApplicationInteraction
      # object :restaurant, class: Restaurant
      array :images

      validate :number_of_images,
               :validate_image_type,
               :validate_image_size

      def execute
        ActiveRecord::Base.transaction do
          @photos = []
          images.each do |img|
            @photos << transactional_create!(Image, { file: img, display_image: img, restaurant: })
          end
          raise ActiveRecord::Rollback if errors.any?
        end
      end

      def to_model
        @photos
      end

      private

      def number_of_images
        return if images.size <= 50

        errors.add(:photos, 'Only 50 images can be uploaded in one request')
        throw(:abort)
      end

      def validate_image_size
        images.each do |img|
          next if img.size <= 12.megabytes

          errors.add(:profile_photo, "#{img&.original_filename} image is too large, max image size is 12mb")
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

          errors.add(:profile_photo, "#{img&.original_filename} file type is invalid, only jpg, jpeg and png is supported")
          throw(:abort)
        end
      end
    end
  end
end
