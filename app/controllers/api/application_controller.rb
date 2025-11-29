# frozen_string_literal: true

module Api
  class ApplicationController < ::ApplicationController
    include ActiveStorage::SetCurrent
    include ::Api::Errors
    # include Pagy::Backend

    after_action :add_pagination_headers

    protect_from_forgery with: :null_session
    respond_to :json
    self.responder = ::ApiResponder

    private

    # def per_page
    #   params[:per_page] || Pagy::DEFAULT[:items]
    # end

    # def page
    #   params[:page]
    # end

    # # Function to paginate a scope
    # # @param [ActiveRecord::Relation] scope
    # # @param [Hash] options
    # # @return [Array]
    # def paginate(scope, **_options)
    #   @pagy, paginated_scope = if scope.is_a?(Array)
    #                              pagy_array(scope.to_a, limit: per_page, page:)
    #                            else
    #                              pagy(scope, limit: per_page, page:)
    #                            end
    #   paginated_scope
    # end

    def array_serializer
      ActiveModel::Serializer::CollectionSerializer
    end

    # @overload add_pagination_headers
    # This callback adds the pagination headers to response
    # Return [Pagy Object]
    # def add_pagination_headers
    #   pagy_headers_merge(@pagy) if @pagy
    # end
  end
end
