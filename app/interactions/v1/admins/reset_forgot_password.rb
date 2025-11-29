# frozen_string_literal: true

module V1
  module Admins
    class ResetForgotPassword < ::ApplicationInteraction
      string :token, :new_password, :confirm_password

      validates :token, :new_password, :confirm_password, presence: true

      validate do
        @admin = Admin.find_by(reset_password_token: token)
        errors.add(:email, :email_error) if @admin.nil?
      end

      def execute
        expired = check_token_expiry?
        return errors.add(:base, :token_expired) if expired

        errors.merge!(@admin.errors) unless @admin.reset_password(new_password, confirm_password)
      end

      def to_model
        @admin.reload
      end

      private

      def check_token_expiry?
        return true unless (Time.current - @admin.reset_password_sent_at) < 10.minutes.to_i

        false
      end
    end
  end
end
