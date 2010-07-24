# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

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
ENV['RPX_KEY'] = '18c3db9c36e3ce844af615637cfc9ffbac08448f'
ENV['RECAPTCHA_PUBLIC_KEY']  = '6LcbaboSAAAAADbBxT9yLOJ7CoLWLsuAfZr-aL-H'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LcbaboSAAAAACJMtxxfExG5dm_GcDHuZl9WVjZG'
 config.gem(
        'thinking-sphinx',
        :lib     => 'thinking_sphinx',
        :version => '1.3.16'
    )