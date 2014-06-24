require File.expand_path('../boot', __FILE__)

# require 'rails/all'
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'docker'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DockerWebUi
  class Application < Rails::Application

    docker_url = ENV['DOCKER_HOST']
    if !docker_url.to_s.empty?
        Docker.url = docker_url
    end

    docker_user  = ENV['DOCKER_USER']
    docker_pass  = ENV['DOCKER_PASS']
    docker_email = ENV['DOCKER_EMAIL']
    if !docker_user.to_s.empty? && !docker_email.to_s.empty? && !docker_pass.to_s.empty?
      begin
        Docker.authenticate!('username' => docker_user, 'password' => docker_pass, 'email' => docker_email)
      rescue => e
        p e.message
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
