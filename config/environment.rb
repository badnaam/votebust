# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_ENV = 'production'
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
    require 'custom_logger'
    #todo change log level in production
    config.log_level = ENV['RAILS_ENV']=='production' ?
      ActiveSupport::BufferedLogger::Severity::DEBUG :
      ActiveSupport::BufferedLogger::Severity::DEBUG

    #   # initializing custom logger
    config.logger = CustomLogger.new(config.log_path, config.log_level)

    RUBY_HEAP_MIN_SLOTS=500000
    RUBY_HEAP_SLOTS_INCREMENT=250000
    RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
    RUBY_GC_MALLOC_LIMIT=50000000
    #    Rails.cache.clear
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**','*.{rb,yml}')]
    config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )
    APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

    #    config.logger = RAILS_DEFAULT_LOGGER = Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log", 'daily')
    #
    # Specify gems that this application depends on and have them installed with rake gems:install
    # config.gem "bj"
    # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
    # config.gem "sqlite3-ruby", :lib => "sqlite3"
    # config.gem "aws-s3", :lib => "aws/s3"

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Skip frameworks you're not going to use. To use Rails without a database,
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    config.gem 'hoptoad_notifier'

    config.gem 'net-ssh', :lib => "net/ssh"
    config.gem "ambethia-recaptcha", :lib => "recaptcha/rails", :source => "http://gems.github.com"
    config.gem "json"
    config.gem 'dalli'
    config.gem "authlogic"
    config.gem "friendly_id", :version => "~> 3.1"
    config.gem 'rakismet'
    config.gem "RedCloth"
    ENV['RECAPTCHA_PUBLIC_KEY']  = APP_CONFIG['recap_pub_key']
    ENV['RECAPTCHA_PRIVATE_KEY'] = APP_CONFIG['recap_priv_key']
    ENV['GOOGLE_JS_API'] = APP_CONFIG['google_js_api']
    ENV['RPX_KEY'] = APP_CONFIG['rpx_key']
    #    ENV['RPX_KEY'] = '18c3db9c36e3ce844af615637cfc9ffbac08448f'
    
    config.time_zone = 'Pacific Time (US & Canada)'
    #    config.gem "openrain-action_mailer_tls", :lib => "smtp_tls.rb", :source => "http://gems.github.com"
    %w(middleware).each do |dir|
        config.load_paths << "#{RAILS_ROOT}/app/#{dir}"
    end
    
    config.gem "badnaam-geokit", :lib => 'geokit', :version => '1.5.1'
    config.gem(
        'thinking-sphinx',
        :lib     => 'thinking_sphinx',
        :version => '1.3.20'
    )
    config.gem 'mime-types', :lib => "mime/types",     :version => '1.16'
    config.gem "authlogic", :source => "http://gems.github.com"
    config.gem "rpx_now"
    config.gem "authlogic_rpx"
    config.gem "formtastic"
    config.gem "validation_reflection"
    config.gem 'delayed_job', :source => 'http://rubygems.org', :version => "2.1.0.pre"
    config.gem "ghazel-daemons", :lib => "daemons", :source => 'http://gems.github.com'
    gem "ghazel-daemons"
    require "daemons"
    
    
    config.gem "declarative_authorization"
    config.gem "searchlogic"
    config.gem 'will_paginate', :lib => 'will_paginate',  :source => 'http://gemcutter.org'

    config.gem 'ts-datetime-delta',
      :lib     => 'thinking_sphinx/deltas/datetime_delta',
      :version => '>= 1.0.2',
      :source  => 'http://gemcutter.org'

    if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
            # Only works with DalliStore
            Rails.cache.reset if forked
        end
    end


    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    
end

#ExceptionNotification::Notifier.sender_address = %w(voteableteam@gmail.com)

#ExceptionNotification::Notifier.exception_recipients = %w(voteableteam@gmail.com)

