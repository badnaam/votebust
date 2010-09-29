class Category < ActiveRecord::Base
    include ExceptionNotification::Notifiable
    
    include ModelHelpers
    has_many :vote_topics, :dependent => :destroy
    #    has_friendly_id :name, :use_slug => true, :cache_column => 'cached_slug'
    has_friendly_id :name, :use_slug => true
    has_many :users, :through => :interests
    has_many :interests
    
    default_scope :order => 'categories.name ASC'

    def refresh_category_cache
        Rails.cache.delete("all_categories")
    end

    def its_new?
        self.new_record?
    end

    def self.all_categories
        Rails.cache.fetch("all_categories_#{list_key}") do
            Category.all(:include => [:slug], :conditions => ['vote_topics_count > ?', 0])
        end
    end

    def self.list_key
        sum(:vote_topics_count)
    end

    def self.test
        begin
        rescue => exp
        end
    end
end
