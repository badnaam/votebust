set :application, "voteable"
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :repository, "git@github.com:badnaam/votebust.git"
set :branch, "master"
set :deploy_via, :remote_cache

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa.pub")]

default_run_options[:pty] = true

set :default_env,  'production'

set :rails_env, ENV['rails_env'] || ENV['RAILS_ENV'] || default_env

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, 'deploy'
set :group, 'www-data'
set :ssh_options, { :forward_agent => true }
#set :use_sudo, true

role :web, "173.230.158.13"                          # Your HTTP server, Apache/etc
role :app, "173.230.158.13"                          # This may be the same as your `Web` server
role :db,  "173.230.158.13", :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
        run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end

    after "deploy:stop" do
        dj_stop
    end
    after "deploy:start" do
        dj_start
    end

    before "deploy:restart" do
        package_assets
    end
    after "deploy:restart" do
        dj_restart
    end

    
    after "deploy:symlink" do
        update_crontab
        chown_to_www_data
    end

    after "deploy:setup" do
        create_shared_dirs
    end
    
    after "deploy:update_code" do
        symlink_shared
#       restart_sphinx
    end

    before "deploy:update" do
        check_in_git
    end

    desc 'Check in pending work to git'
    task :check_in_git do
        system 'git add .'
        system "git commit -m 'automated check in'"
        system "git push origin master"
    end

    desc "Create shared links"
    task :symlink_shared, :roles => :app  do
        #Copy the files firest
        top.upload("config/database.yml", "#{shared_path}/config", :via => :scp)
        #generate_sphinx_config_yaml
        top.upload("config/sphinx.yml", "#{shared_path}/config", :via => :scp)
        top.upload("config/config.yml", "#{shared_path}/config", :via => :scp)
        run "ln -nfs #{shared_path}/sphinx #{release_path}/db/sphinx"
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
        run "ln -nfs #{shared_path}/config/sphinx.yml #{release_path}/config/sphinx.yml"
        #        run "ln -nfs #{shared_path}/config/sphinx.conf #{release_path}/config/sphinx.conf"
        run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
        run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
    end

    desc "Create additional shared directories"
    task :create_shared_dirs do
        run "mkdir -p #{shared_path}/assets/images/users"
        run "run if [[ -d #{shared_path}/assets/images/users ]] then; else mkdir -p #{shared_path}/assets/images/users; fi"
        run "mkdir #{shared_path}/config"
        run "mkdir #{shared_path}/db"
        run "mkdir #{shared_path}/sphinx"
    end

    desc "Change group to www-data"
    task :chown_to_www_data, :roles => [ :app, :db, :web ] do
        sudo "chown -R #{user}:www-data #{deploy_to}"
        sudo "chmod -R 755 #{deploy_to}"
    end

    task :create_sphinx_db_dir, :roles => :app do
        run "mkdir -p #{shared_path}/sphinx"
    end

    task :install_log_rotate_script, :roles => :app do
        rotate_script = %Q{#{shared_path}/log/#{rails_env}.log {
        daily
        rotate 14
        size 5M
        compress
        create 640 #{user} #{group}
        missingok
        }}
        put rotate_script, "#{shared_path}/logrotate_script"
        sudo "cp #{shared_path}/logrotate_script /etc/logrotate.d/#{application}"
        delete "#{shared_path}/logrotate_script"
    end

    task :package_assets do
        set :rake_cmd, "asset:packager:build_all"
        rake_exec
    end
    
    set :rake_cmd, (ENV['RAKE_CMD'] || nil)

    task :rake_exec do
        if rake_cmd
            run "cd #{current_path} && rake #{rake_cmd} RAILS_ENV=#{rails_env}"
        end
    end

    # Clear file-based fragment and/or page cache
    task :clear_cache do
        # I usually make a custom Rake task for this
        set :rake_cmd, "tmp:cache:clear"
        rake_exec
    end


    ######################Sphinx configuration#####################

    desc 'Generate a config yaml in shared path'
    task :generate_sphinx_config_yaml, :roles => :app do
        config = {"morphology" => "stem_en", "config_file" => "#{shared_path}/config/sphinx.conf",
            "searchd_log_file" => "#{shared_path}/log/searchd.log",
            "query_log_file" => "#{shared_path}/log/searchd.query.log",
            "pid_file" =>  "#{shared_path}/log/searchd.#{rails_env}.pid",
            "mem_limit"=> "20M",
            "enable_star" => true,
            "searchd_file_path" => "#{shared_path}/sphinx"
        }
        put config.to_yaml, "#{shared_path}/config/sphinx.yml"
    end

    desc "Stop the sphinx server"
    task :stop_sphinx , :roles => :app do
        run "cd #{release_path} && rake  thinking_sphinx:stop RAILS_ENV=#{rails_env}"
    end

    desc "Start the sphinx server”"
    task :start_sphinx, :roles => :app do
#        run "cd #{release_path} && rake thinking_sphinx:configure RAILS_ENV=#{rails_env} && rake thinking_sphinx:start RAILS_ENV=#{rails_env}"
        run "cd #{release_path} &&  rake thinking_sphinx:start RAILS_ENV=#{rails_env}"
    end

    desc "Restart the sphinx server"
    task :restart_sphinx, :roles => :app do
        stop_sphinx
        start_sphinx
    end

    ###########################update cron tab with whenever ################################
    desc "Update the crontab file"
    task :update_crontab, :roles => :db do
        run "cd #{release_path} && whenever --set environment=production --update-crontab #{application}"
    end

    ##########################################################################################
    #################Delayed job#############################################################
    def get_rails_env
        fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
    end

    desc "Stop the delayed_job process"
    task :dj_stop, :roles => :app do
        run "cd #{current_path};#{get_rails_env} script/delayed_job stop"
    end

    desc "Start the delayed_job process"
    task :dj_start, :roles => :app do
        run "cd #{current_path};#{get_rails_env} script/delayed_job start"
    end

    desc "Restart the delayed_job process"
    task :dj_restart, :roles => :app do
        run "cd #{current_path};#{get_rails_env} script/delayed_job stop"
        run "cd #{current_path};#{get_rails_env} script/delayed_job start"
#        run "cd #{current_path};#{get_rails_env} script/delayed_job restart"
        #        dj_ensure
    end

    desc "Show delayed_job daemon status."
    task :dj_status, :roles => :app do
        run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=#{rails_env} script/delayed_job status; fi"
    end

    desc "List the PIDs of all running delayed_job daemons."
    task :dj_pids, :roles => :app do
        run "sudo lsof | grep '#{deploy_to}/shared/log/delayed_job.log' | cut -c 1-21 | uniq | awk '/^ruby/ {if(NR > 0){system(\"echo \" $2)}}'"
    end

    desc "Kill all running delayed_job daemons."
    task :dj_kill, :roles => :app do
        run "sudo lsof | grep '#{deploy_to}/shared/log/delayed_job.log' | cut -c 1-21 | uniq | awk '/^ruby/ {if(NR > 0){system(\"kill -9 \" $2)}}'"
        run "if [-d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=#{rails_env} script/delayed_job stop; fi" # removes orphaned pid file(s)
    end

    task :dj_ensure, :roles => :app do
        pid_from_file = capture("cat #{current_path}/tmp/pids/delayed_job.pid").strip
        running_pids = capture("ps -ef | grep [d]elayed_job").split("\n").map { |x| x.split[1] }
        if pid_from_file != running_pids.first || running_pids.size != 1
            puts ("-"*80).console_purple
            puts "Something is terribly wrong with delayed job!".console_red
            puts "Running_pid: #{pid_from_file}"
            puts "Running delayed job processes: #{capture("ps -ef | grep [d]elayed_job")}"
            puts ("-"*80).console_purple
        end
    end
end



Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

#require 'hoptoad_notifier/capistrano'
