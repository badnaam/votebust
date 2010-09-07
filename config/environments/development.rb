# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

#require 'active_support/cache/dalli_store23'
require 'no_store'
config.cache_store = :no_store
#CACHE = Dalli::Client.new('localhost:11211')
CACHE = ActiveSupport::Cache::NoStore.new

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true
config.action_mailer.default_url_options = {:host => "localhost", :port => "3000"}
config.action_mailer.default_charset = "utf-8"
#config.cache_store = :mem_cache_store
config.gem "rails-footnotes"
#config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
#if defined?(Footnotes)
#    Footnotes::Filter.prefix = 'editor://open?url=file://%s&amp;line=%d&amp;column=%d'
#end
