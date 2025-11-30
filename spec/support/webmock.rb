# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    # Stub Google Translate API requests (translate endpoint)
    stub_request(:post, %r{translate\.googleapis\.com/language/translate/v2})
      .to_return(
        status: 200,
        body: {
          data: {
            translations: [
              { translatedText: 'Texto traducido' }
            ]
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub Google Translate detect language requests
    stub_request(:post, /translate\.googleapis\.com.*detect/)
      .to_return(
        status: 200,
        body: {
          data: {
            detections: [
              [{ language: 'en', confidence: 0.99 }]
            ]
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub Toast API authentication requests
    stub_request(:post, %r{authentication/v1/authentication/login})
      .to_return(
        status: 200,
        body: {
          token: {
            accessToken: 'mock_toast_token_123',
            expiresIn: 3600
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub Toast API employee requests
    stub_request(:get, %r{labor/v1/employees})
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub Toast API job requests
    stub_request(:get, %r{labor/v1/jobs})
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
