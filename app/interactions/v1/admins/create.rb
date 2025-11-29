# frozen_string_literal: true

module V1
  module Admins
    class Create < Base
      object :admin
      string :first_name, :last_name, :phone_no, :email, :username

      validates :first_name, :last_name, :phone_no, :email, :username, presence: true
      validate :check_admin

      def execute
        ActiveRecord::Base.transaction do
          create_restaurant_admin
          assign_top_level_access if top_level_access.present?
          assign_instance_level_access if instance_level_access.present?

          raise ActiveRecord::Rollback if errors.any?

          AdminMailer.create_restaurant_admin(@restaurant_admin).deliver_now
        end
      end

      private

      def check_admin
        errors.add(:unauthorized, :unauthorized_error) unless admin.superadmin?
      end

      def create_restaurant_admin
        payload = inputs.except(:admin,
                                :top_level_access,
                                :instance_level_access).merge(password: generate_password)
        @restaurant_admin = transactional_create!(Admin, payload)
      end

      def generate_password
        random_upcase_string = ('A'..'Z').to_a.shuffle.join[0]
        random_integer = ('0'..'9').to_a.shuffle.join[0..2]
        random_string = ('a'..'z').to_a.shuffle.join[0..6]
        random_special_character = %w[! # $ % & * + -].shuffle.join[0]
        random_upcase_string + random_string + random_special_character + random_integer
      end
    end
  end
end
