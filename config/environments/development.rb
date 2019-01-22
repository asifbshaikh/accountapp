#require 'sidekiq/testing/inline'

Profitnext::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  #Email settings for SMTP via development
  config.action_mailer.delivery_method = :smtp

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  SimpleCaptcha.image_magick_path = '/usr/local/bin/' # you can check this from console by running: which convert

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  Profitnext::Application.config.session_store :cookie_store, :key => "_profitnext_session" , :domain => "localhost" #, :expire_after => 3.minutes
end

