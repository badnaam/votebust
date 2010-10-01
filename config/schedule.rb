# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#v_env = 'development'




case @environment

when 'production'
    job_type :prod_bg_rake, "cd :path && RAILS_ENV=production_bg /usr/bin/env rake :task"
    
    set :path, '/var/www/voteable'
    every 30.minutes do
        rake "process_votes"
    end
    every 1.days, :at => '10pm' do
        rake "ts:index"
    end
    every 60.minutes do
        rake "ts:in:delta"
    end
    every 2.hours do
        #        rake "facet_update_start"
        prod_bg_rake "facet_update_start"
    end
    every 55.minutes do
        rake "check_for_spam"
    end
    every 1.days, :at => '11am' do
        rake "update_vote_topic_flags"
    end
    every :reboot do
        rake "ts:start RAILS_ENV=production"
        command "cd #{path} && script/delayed_job start RAILS_ENV=production"
        #todo change memcached parameters
        #        command "memcached -d -m 16 -l 127.0.0.1 -p 11211"
    end
    ############## for development
when 'development'
    set :path, '/home/asit/Apps/nap_on_it'
    
    
    every 10.minutes do
        prod_bg_rake "something"
    end

    
    every :reboot do
        rake "ts:start RAILS_ENV=development"
        command "cd #{path} && script/delayed_job start RAILS_ENV=development"
        #        command "memcached -d -m 16 -l 127.0.0.1 -p 11211"
    end
    #    every 10.minutes do
    #        rake "process_votes"
    #    end
    every 120.minutes do
        rake "facet_update_start"
    end
    #    every 1.minutes do
    #        rake "log_test"
    #    end

end

