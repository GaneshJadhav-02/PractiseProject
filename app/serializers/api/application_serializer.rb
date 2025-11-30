# frozen_string_literal: true

module Api
  class ApplicationSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    def utc(datetime)
      datetime ? datetime.utc.to_i : nil
    end

    def created_at
      utc(object&.created_at)
    end

    def updated_at
      utc(object&.updated_at)
    end

    def run_serializer(object_name, serializer_name)
      ::ActiveModelSerializers::SerializableResource.new(object_name, serializer: serializer_name)
    end
  end
end
