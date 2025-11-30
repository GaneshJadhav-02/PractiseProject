# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.3'
gem 'rails', '~> 7.1.3', '>= 7.1.3.4'
gem 'sprockets-rails'

# For environment variables
gem 'dotenv'

gem 'importmap-rails'
gem 'jbuilder'
gem 'puma', '>= 5.0'
gem 'stimulus-rails'
gem 'turbo-rails'

# Use Redis for caching
gem 'redis', '>= 4.0.1'

gem 'bootsnap', require: false
gem 'tzinfo-data'

# For connecting to postgresql database
gem 'pg'

gem 'ffi', '1.17.0', platforms: [:ruby]

# For formatting the json response
gem 'active_interaction'
gem 'active_model_serializers'
gem 'apipie-rails' # api documentation

# For authentication
gem 'devise', '~> 4.9'
gem 'slim-rails'

# images
gem 'active_storage_base64'
gem 'active_storage-blurhash'
gem 'active_storage_validations'
gem 'image_processing'
gem 'mini_magick'

gem 'bootstrap'
gem 'faker'
gem 'font-awesome-rails'
gem 'sass-rails'

gem 'api-pagination'
gem 'pagy'

gem 'rack-cors' # for cross origin requests

gem 'annotate' # for adding schema to models

gem 'aws-sdk-s3'
gem 'exception_notification'
gem 'mail'
gem 'paper_trail'
gem 'rubyXL', '~> 3.3', '>= 3.3.21'
gem 'sidekiq'
gem 'typhoeus'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'pry-byebug'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  # gem 'rspec-rails', '~> 6.1.0'
  # A library for setting up Ruby objects as test data.
  gem 'factory_bot_rails'
  # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'pry'
  # Patch-level verification for Bundler
  gem 'bundler-audit'
  # A static analysis security vulnerability scanner for Ruby on Rails applications
  gem 'brakeman'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'bullet'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  # Strategies for cleaning databases in Ruby. Can be used to ensure a clean state for testing.
  gem 'database_cleaner-active_record'
end
gem 'jsonapi-serializer'
