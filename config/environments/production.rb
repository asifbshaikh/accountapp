Profitnext::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

#mandrill mail test setting
 # config.action_mailer.smtp_settings = {
 #           :address => "smtp.mandrillapp.com",
 #           :port => 587,
 #           :user_name=> "tntpb",
 #           :password=> "7a60a8e4-731e-4572-83e3-1c00f9a8c1d1"
 # }
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
 ####commented for captcha#### 
  #config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
    config.log_level = :error

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Compress JavaScript and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline
  config.assets.compile = true
  config.assets.precompile += ['application.css', 'home.css']
  # Generate digests for assets URLs
  config.assets.digest = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #sets the session store to use subdomains in production
  Profitnext::Application.config.session_store :cookie_store, :key => '_profitnext_session' , :domain => '.profitnext.com', :expire_after => 60.minutes


end
