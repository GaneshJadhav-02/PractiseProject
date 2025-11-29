# frozen_string_literal: true

module Api
  module Errors
    extend ActiveSupport::Concern

    included do
      rescue_from ActionController::ParameterMissing, with: :required_param!
      rescue_from ActiveRecord::RecordNotFound, with: :not_found!
      rescue_from ActionController::UnknownFormat, with: :bad_request!

      def unauthorized!
        render json: { error: t('api.errors.unauthorized') }, status: 401
      end

      def wrong_access!
        render json: { error: t('api.errors.wrong_access') }, status: 403
      end

      def not_found!
        render json: { error: t('api.errors.not_found') }, status: 404
      end

      def bad_request!
        render json: { error: t('api.errors.bad_request') }, status: 400
      end

      def unconfirmed_user!
        render json: { error: t('api.errors.unconfirmed_user') }, status: 403
      end

      def confirmed_user!
        render json: { error: t('api.errors.confirmed_user') }, status: :unprocessable_content
      end

      def required_param!(exception)
        error_message = (t('api.errors.param_is_required') % { attribute: exception.param })&.capitalize
        render json: { errors: { exception.param => error_message } }, status: :unprocessable_content
      end
    end
  end
end
