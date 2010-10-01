class Category < ActiveRecord::Base
    
    include ModelHelpers
    has_many :vote_topics, :dependent => :destroy
    #    has_friendly_id :name, :use_slug => true, :cache_column => 'cached_slug'
    has_friendly_id :name, :use_slug => true
    has_many :users, :through => :interests
    has_many :interests

    after_create :refresh_category_cache
    
    default_scope :order => 'categories.name ASC'

    def refresh_category_cache
        Rails.cache.delete("all_categories")
    end

    def its_new?
        self.new_record?
    end

    def self.filled_categories
        Rails.cache.fetch("filled_categories_#{list_key}") do
            Category.all(:include => [:slug], :conditions => ['vote_topics_count > ?', 0])
        end
    end
    
    def self.all_categories
        Rails.cache.fetch("all_categories") do
            Category.all(:include => :slug)
        end
    end

    def self.list_key
        sum(:vote_topics_count)
    end
end
