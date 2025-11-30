# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

module Faker
  class Phone
    def self.number
      [
        '+15417543010',
        '+13210441203',
        '+15344419477',
        '+15344419477',
        '+17490364528',
        '+19168302827'
      ].sample
    end
  end
end
