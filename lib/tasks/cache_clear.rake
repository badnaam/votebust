
namespace :cache_clear do
    desc 'clear a page cache'
    task :expire_cache => :environment do
        ActionController::Base::expire_page('/')
        puts "Cache cleared"
    end

    task :test  do |t, args|
        puts args[0]
        puts args[1]
    end
end