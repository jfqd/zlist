require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module Zlist
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    # Set application ENV variables from a YAML file
    # In production (on Heroku), these should be set using built-in config vars
    YAML.load(File.read("#{Rails.root}/config/app_config.yml"))[Rails.env].each do |k, v|
      ENV[k] ||= v
    end
   
    # Select delivery method
    if File.exists?("#{Rails.root}/config/email.yml")
      # Load Mailserver settings
      config.action_mailer.perform_deliveries = true
      YAML.load(File.read("#{Rails.root}/config/email.yml"))[Rails.env].each do |k, v|
        v.symbolize_keys! if v.respond_to?(:symbolize_keys!)
        ActionMailer::Base.send("#{k}=", v)
      end
    else
      # Send email using Postmark
      config.action_mailer.delivery_method   = :postmark
      config.action_mailer.postmark_settings = { :api_key => ENV['POSTMARK_API_KEY'] }
    end
   
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)
  end
end
