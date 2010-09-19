class Category < ActiveRecord::Base
    include ModelHelpers
    has_many :vote_topics
    has_friendly_id :name, :use_slug => true, :cache_column => 'cached_slug'
    default_scope :order => 'name ASC'

    after_save :refresh_category_cache, :if => Proc.new {ModelHelpers.prod?}

    
    def refresh_category_cache
        Rails.cache.delete 'views/category_nav'
    end
end
