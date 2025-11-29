# frozen_string_literal: true

module V1
  module Admins
    class SignOut < ::ApplicationInteraction
      object :admin, class: ::Admin

      def execute
        admin.tokens.destroy_all
      end

      def to_model
        { message: 'Admin logged out successfully !' }
      end
    end
  end
end
