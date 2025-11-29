# frozen_string_literal: true

module V1
  module Admins
    class SoftDelete < Base
      object :admin, class: Admin
      object :restaurant_admin, class: Admin
      string :reason, default: nil

      validate :check_permissions
      validate :check_last_super_admin

      def execute
        ActiveRecord::Base.transaction do
          perform_soft_delete
          create_audit_log

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      private

      def check_permissions
        errors.add(:unauthorized, :unauthorized_error) unless admin.superadmin?
      end

      def check_last_super_admin
        return unless restaurant_admin.superadmin?

        super_admin_count = Admin.all.select(&:superadmin?).count
        return unless super_admin_count <= 1

        user_name = "#{restaurant_admin.first_name} #{restaurant_admin.last_name}"
        errors.add(:base, "Cannot delete this user as #{user_name} is the last active Super Admin. Please promote another user to Super Admin before proceeding.")
      end

      def perform_soft_delete
        restaurant_admin.soft_delete!(actor: admin, reason: reason)
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:base, e.message)
      end

      def create_audit_log
        return if errors.any?

        restaurant_admin.paper_trail.save_with_version(
          event: 'ACCOUNT_DELETED',
          whodunnit: admin.id,
          object_changes: {
            action: 'soft_delete',
            deleted_by: admin.id,
            deleted_at: restaurant_admin.deleted_at,
            reason: reason,
            quarantine_expires_at: restaurant_admin.quarantine_expires_at
          }.to_json
        )
      end
    end
  end
end
