class Category < ActiveRecord::Base
    include ModelHelpers
    has_many :vote_topics, :dependent => :destroy
#    has_friendly_id :name, :use_slug => true, :cache_column => 'cached_slug'
    has_friendly_id :name, :use_slug => true
    default_scope :order => 'categories.name ASC'

   after_save :refresh_category_cache, :if => :its_new?


    def its_new?
        self.new_record?
    end
    
    def refresh_category_cache
#        Rails.cache.delete 'views/category_nav'
    end
end
