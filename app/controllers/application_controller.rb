# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def append_info_to_payload(payload)
    super
    payload[:body_response] = response.media_type == 'application/json' ? response.body : response.media_type
  end
end
