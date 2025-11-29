# frozen_string_literal: true

module V1
  module Admins
    class Restore < Base
      object :admin, class: Admin
      object :restaurant_admin, class: Admin

      validate :check_permissions
      validate :check_quarantined

      def execute
        ActiveRecord::Base.transaction do
          restore_admin_account
          create_audit_log

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      private

      def check_permissions
        errors.add(:unauthorized, :unauthorized_error) unless admin.superadmin?
      end

      def check_quarantined
        errors.add(:base, 'Admin is not quarantined') unless restaurant_admin.quarantined?
      end

      def restore_admin_account
        restaurant_admin.restore!(_actor: admin)
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:base, e.message)
      end

      def create_audit_log
        return if errors.any?

        restaurant_admin.paper_trail.save_with_version(
          event: 'ACCOUNT_RESTORED',
          whodunnit: admin.id,
          object_changes: {
            action: 'restore',
            restored_by: admin.id,
            restored_at: Time.current
          }.to_json
        )
      end
    end
  end
end
