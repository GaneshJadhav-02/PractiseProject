# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

%w[200 201 401 403 404 422 400].each do |code|
  RSpec.shared_examples "response_#{code}" do |options = {}|
    it "response should have #{code} status", options do
      subject
      expect(response.code).to eq(code)
    end
  end
end
