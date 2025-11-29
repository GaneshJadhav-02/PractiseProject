# frozen_string_literal: true

module V1
  module Admins
    class Purge < Base
      object :admin, class: Admin
      object :restaurant_admin, class: Admin

      validate :check_permissions
      validate :check_quarantined

      def execute
        ActiveRecord::Base.transaction do
          create_audit_log_before_delete
          remove_from_permit_io
          permanently_delete_admin

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      private

      def check_permissions
        errors.add(:unauthorized, :unauthorized_error) unless admin.superadmin?
      end

      def check_quarantined
        errors.add(:base, 'Admin must be quarantined before purging') unless restaurant_admin.quarantined?
      end

      def create_audit_log_before_delete
        return if errors.any?

        restaurant_admin.paper_trail.save_with_version(
          event: 'ACCOUNT_PURGED',
          whodunnit: admin.id,
          object_changes: {
            action: 'purge',
            purged_by: admin.id,
            purged_at: Time.current,
            admin_email: restaurant_admin.email,
            admin_username: restaurant_admin.username
          }.to_json
        )
      end

      def remove_from_permit_io
        return if errors.any?
        return if Rails.env.test?

        ::PermitIO.api.users.delete(restaurant_admin.id.to_s)
      rescue OpenapiClient::ApiError => e
        return if e.code == 404

        errors.add(:base, "Failed to remove from Permit.io: #{e.message}")
      rescue StandardError => e
        errors.add(:base, "Failed to remove from Permit.io: #{e.message}")
      end

      def permanently_delete_admin
        return if errors.any?

        restaurant_admin.purge!(_actor: admin)
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
        errors.add(:base, e.message)
      end
    end
  end
end
