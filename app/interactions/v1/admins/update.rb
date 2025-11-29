# frozen_string_literal: true

module V1
  module Admins
    class Update < Base
      object :restaurant_admin, class: Admin
      object :admin
      string :first_name, :last_name, :phone_no, :email, :username, :language_preference, default: nil
      array :delete_top_level, default: [] do
        string
      end
      array :delete_instance_level, default: [] do
        hash do
          string :role
          string :resource_instance
        end
      end

      validate :check_admin
      validate do
        admin_params.each_key do |attr|
          errors.add(attr, :blank) if send(attr) && send(attr).empty?
        end
      end

      def execute
        Admin.transaction do
          transactional_update!(restaurant_admin, admin_params.compact)
          configure_permissions

          raise ActiveRecord::Rollback if errors.any?
        end
      end

      private

      def check_admin
        errors.add(:unauthorized, :unauthorized_error) unless admin.superadmin?
      end

      def configure_permissions
        assign_top_level_access if top_level_access.present?
        delete_top_level_access if delete_top_level.present?
        assign_instance_level_access if instance_level_access.present?
        delete_instance_level_access if delete_instance_level.present?
      end

      def unassign_role(role, resource_instance = nil)
        ::PermitIO.api.role_assignments.unassign_role_of_admin(
          { role:,
            resource_instance:,
            user: restaurant_admin.id.to_s }
        )
      rescue StandardError => e
        errors.add(:role, e.message)
      end

      def delete_top_level_access
        delete_top_level.each do |role|
          unassign_role(role)
        end
      end

      def delete_instance_level_access
        delete_instance_level.each do |permission|
          unassign_role(permission[:role], permission[:resource_instance])
        end
      end

      def admin_params
        inputs.except(:restaurant_admin,
                      :admin, :top_level_access,
                      :instance_level_access,
                      :delete_top_level, :delete_instance_level)
      end
    end
  end
end
