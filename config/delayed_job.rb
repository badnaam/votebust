# delayed_job
namespace :dj do

  desc "Start delayed_job daemon."
  task :start, :roles => :app do
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=#{rails_env} script/delayed_job start; fi"
  end

  desc "Stop delayed_job daemon."
  task :stop, :roles => :app do
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=#{rails_env} script/delayed_job stop; fi"
  end

  desc "Restart delayed_job daemon."
  task :restart, :roles => :app do
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=#{rails_env} script/delayed_job restart; fi"
  end

  desc "Show delayed_job daemon status."
  task :status, :roles => :app do
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=#{rails_env} script/delayed_job status; fi"
  end

  desc "List the PIDs of all running delayed_job daemons."
  task :pids, :roles => :app do
    run "sudo lsof | grep '#{deploy_to}/shared/log/delayed_job.log' | cut -c 1-21 | uniq | awk '/^ruby/ {if(NR > 0){system(\"echo \" $2)}}'"
  end

  desc "Kill all running delayed_job daemons."
  task :kill, :roles => :app do
    run "sudo lsof | grep '#{deploy_to}/shared/log/delayed_job.log' | cut -c 1-21 | uniq | awk '/^ruby/ {if(NR > 0){system(\"kill -9 \" $2)}}'"
    run "if [-d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=#{rails_env} script/delayed_job stop; fi" # removes orphaned pid file(s)
  end

end