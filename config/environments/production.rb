# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
require 'active_support/cache/dalli_store23'
config.cache_store = :dalli_store
CACHE = Dalli::Client.new('localhost:11211')

config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true



# See everything in the log (default is :info)
config.log_level = :debug
config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true
config.action_mailer.default_url_options = {:host => "server"}
config.action_mailer.default_charset = "utf-8"
ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    #        :domain => I18n.translate('notifier.domain'),
    :domain => 'gmail.com',
    :user_name => 'pjointadm@gmail.com',
    :password => "badnaam1",
    :authentication => :plain,
    :enable_starttls_auto => true
}

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!