class Tracking < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic, :counter_cache => true
    validates_uniqueness_of :vote_topic_id, :scope => :user_id

    after_create :refresh_caches
    after_destroy :refresh_caches

    def refresh_caches
#        Rals.cache.delete("trackings_limited_#{self.user.id}")
#        Rals.cache.delete("trackings_all_#{self.user.id}")
    end
end
