# frozen_string_literal: true

module V1
  module Admins
    class ResetPassword < ::ApplicationInteraction
      string :new_password, :confirm_password, :email

      validates :new_password, :confirm_password, presence: true

      validate do
        @admin = Admin.find_by(email:)
        errors.add(:email, :email_error) if @admin.nil?
      end

      def execute
        errors.merge!(@admin.errors) unless @admin.reset_password(new_password, confirm_password)
        @admin.update(password_changed: true)
      end

      def to_model
        @admin.reload
      end
    end
  end
end
