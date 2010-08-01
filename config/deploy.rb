set :application, "votechek"
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :repository, "git@github.com:badnaam/votebust.git"
set :branch, "master"
set :deploy_via, :remote_cache
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
        run "chmod -R 0666 #{current_path}/log"
        run "chmod -R 755 #{current_path}/log"
    end
end