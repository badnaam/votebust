class Tracking < ActiveRecord::Base
    belongs_to :follower, :class_name => "User", :foreign_key => :user_id
    belongs_to :tracked_vote_topic, :class_name => "VoteTopic", :foreign_key => :vote_topic_id, :counter_cache => true

    after_create :increment_tracking_cache
    after_destroy :decrement_tracking_cache
    
    validates_uniqueness_of :vote_topic_id, :scope => :user_id

    def increment_tracking_cache
        CacheUtil.increment("vt_tracking_#{self.tracked_vote_topic.id}", 1)
    end

    def decrement_tracking_cache
        CacheUtil.decrement("vt_tracking_#{self.tracked_vote_topic.id}", 1)
    end
end
