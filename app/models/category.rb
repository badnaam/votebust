class Category < ActiveRecord::Base
    has_many :vote_topics
    has_friendly_id :name, :use_slug => true, :cache_column => 'cached_slug'

end
