# frozen_string_literal: true

module V1
  module Admins
    class ForgotPassword < ::ApplicationInteraction
      string :email

      validates :email, presence: true

      validate do
        @admin = Admin.find_by(email:)
        errors.add(:email, :email_error) if @admin.nil?
      end

      def execute
        token = generate_token
        errors.merge!(@admin.errors) unless @admin.update(reset_password_token: token, reset_password_sent_at: Time.current)
        AdminMailer.reset_password_link(@admin, token).deliver_now
      end

      def to_model
        @admin.reload
      end

      private

      def generate_token
        SecureRandom.hex(20)
      end
    end
  end
end
