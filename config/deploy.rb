set :application, "votechek"
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :repository, "git@github.com:badnaam/votebust.git"
set :branch, "master"
set :deploy_via, :remote_cache
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa.pub")]
default_run_options[:pty] = true

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, 'asit'
set :ssh_options, { :forward_agent => true }

role :web, "server"                          # Your HTTP server, Apache/etc
role :app, "server"                          # This may be the same as your `Web` server
role :db,  "server", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
        run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
   
    after "deploy:symlink" do
        chown_to_www_data
#        run "sudo chmod -R 0666 #{current_path}/log"
#        run "sudo chmod -R 755 #{current_path}/log"
    end

    before "deploy:update" do
        check_in_git
    end

    desc 'Check in pending work to git'
    task :check_in_git do
        system 'git add .'
        system "git commit -m 'automated check in'"
        system "git push origin master'"
    end

    desc "Change group to www-data"
    task :chown_to_www_data, :roles => [ :app, :db, :web ] do
        sudo "chown -R #{user}:www-data #{deploy_to}"
        sudo "chmod -R 755 #{deploy_to}"
    end 
end