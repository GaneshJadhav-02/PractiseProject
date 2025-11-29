# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.hosts.clear
    config.autoload_lib(ignore: %w[assets tasks api openapi_client])
    config.active_storage.content_types_to_serve_as_binary.delete('image/svg+xml')
    config.middleware.insert_before 0, Rack::Cors do
      exposed = %w[Current-Page Total-Count Page-Items Total-Pages]

      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get delete post put patch], expose: exposed
      end
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
