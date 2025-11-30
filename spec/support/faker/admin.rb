# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

module Faker
  class Admin
    def self.username
      usrnm = Faker::Internet.unique.username
      "#{usrnm}#{6.times.map { (rand * 10).to_i }.join}".gsub(/[^0-9a-z ]/i, '').first(10)
    end
  end
end
