# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

module AuthHelper
  def get_auth_token(owner)
    Authorizer.generate_token(owner)
  end
end
