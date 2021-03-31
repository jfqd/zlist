require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ENV["RAILS_ENV"] ||= ENV["RACK_ENV"] ||= "production"
Dotenv.load ".env.#{ENV["RAILS_ENV"]}", '.env'

module Zlist
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Select delivery method
    if File.exists?("#{Rails.root}/config/email.yml")
      # Load Mailserver settings
      config.action_mailer.perform_deliveries = true
      YAML.load(File.read("#{Rails.root}/config/email.yml"))[Rails.env].each do |key, value|
        value = Hash.new.tap do |rendered_hash|
          value.each { |k,v|
            if v.is_a? String
              renderer = ERB.new(v)
              v = renderer.result()
            end
            rendered_hash[k] = v
          }
        end if value.is_a? Hash
        value.symbolize_keys! if value.respond_to?(:symbolize_keys!)
        ActionMailer::Base.send("#{key}=", value)
      end
    else
      # Send email using Postmark
      config.action_mailer.delivery_method   = :postmark
      config.action_mailer.postmark_settings = { :api_key => ENV['POSTMARK_API_KEY'] }
    end
   
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
