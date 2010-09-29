namespace :cache_clear do

    desc 'clears memcached'
    task :memcache => :environment do
        Rails.cache.clear
    end
    
    desc 'clear js and css cache'
    task :clear_js_css_cache => :environment do
        css_cache_file = File.join(RAILS_ROOT, "public", "stylesheets", "base.css")
        js_cache_file = File.join(RAILS_ROOT ,"public", "javascripts", "base.js")
        if File.exists?(css_cache_file)
            puts "Deleting #{css_cache_file}"
            File.delete(css_cache_file)
        end
        if File.exists?(js_cache_file)
            puts "Deleting #{js_cache_file}"
            File.delete(js_cache_file)
        end
    end

    desc 'clear page cache'
    task :clear_page_cache => :environment do
        cache_dir = ActionController::Base.page_cache_directory
        unless cache_dir == RAILS_ROOT+"/public"
            puts 'Deleting cache_dir'
            FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
        end
    end

    desc 'clear page, css and js cache'
    task :clear_all_cache => [:environment, :clear_js_css_cache, :test] do
    end
    
    task :test  do |t, args|
        puts "asit"
    end
end