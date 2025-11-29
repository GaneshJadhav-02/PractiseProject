# frozen_string_literal: true

module V1
  module Admins
    class Base < ::ApplicationInteraction
      attr_reader :restaurant_admin

      array :top_level_access, default: [] do
        string
      end
      array :instance_level_access, default: [] do
        hash do
          string :role
          string :resource_instance
        end
      end

      def to_model
        restaurant_admin.reload
      end

      private

      def assign_roles(role, resource_instance = nil)
        ::PermitIO.api.role_assignments.assign_role_to_admin(
          { role:,
            resource_instance:,
            user: restaurant_admin.id.to_s }
        )
      rescue StandardError => e
        errors.add(:role, e.message)
      end

      def assign_top_level_access
        top_level_access.each do |role|
          assign_roles(role)
        end
      end

      def assign_instance_level_access
        instance_level_access.each do |permission|
          assign_roles(permission[:role], permission[:resource_instance])
        end
      end
    end
  end
end
