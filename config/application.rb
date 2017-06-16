require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module UrlGrey
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Customize your application's name
    config.application_name = 'URL Grey'
    config.application_host = 'https://grz.li'

    # Optionally set '/' as a short URL. This will only have effect
    ## if the app can find a ShortUrl with slug 'root' to redirect to
    config.root_redirect_enabled  = true

    # Set random slug default length
    config.random_slug_length = 4

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
