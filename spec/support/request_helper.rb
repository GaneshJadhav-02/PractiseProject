# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

module RequestHelper
  def json
    JSON.parse(response.body)
  end

  def json_equal?(objects)
    json.each_index do |index|
      keys.each do |key|
        return false unless json[index][key].eql?(objects[index][key])
      end
    end

    true
  end
end
