require 'capitate'
require 'capitate/recipes'
set :project_root, File.dirname(__FILE__)

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

#load 'config/delayed_job'
load 'config/deploy' # remove this line to skip loading any of the default tasks
