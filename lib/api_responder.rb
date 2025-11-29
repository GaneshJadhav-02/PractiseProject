# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

class ApiResponder < ::ActionController::Responder
  def api_behavior
    raise MissingRenderer.new(format) unless has_renderer?
    answer = resource.try(:to_model) || resource
    if get?
      display answer
    elsif post?
      display answer, status: :created
    elsif has_errors?
      display answer, status: :unprocessable_content
    else
      display answer
    end
  end

  def display_errors
    controller.render format => resource_errors, status: :unprocessable_content
  end
end
