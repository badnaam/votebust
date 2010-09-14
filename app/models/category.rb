class Category < ActiveRecord::Base
    has_many :vote_topics
    has_friendly_id :name, :use_slug => true, :cache_column => 'cached_slug'
    default_scope :order => 'name ASC'

    after_save :refresh_category_cache

    def self.get_cat
        if Rails.env == 'production'
            CACHE.fetch "all_category" do
                all
            end
        else
            Category.all
        end
    end

    def refresh_category_cache
        categories = Category.all
        CACHE.set 'all_category', categories
    end
end
