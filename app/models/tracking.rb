class Tracking < ActiveRecord::Base
    belongs_to :follower, :class_name => "User", :foreign_key => :user_id
    belongs_to :tracked_vote_topic, :class_name => "VoteTopic", :foreign_key => :vote_topic_id, :counter_cache => true

    after_create :add_reward, :reset_tracking_cache
    after_destroy :remove_reward, :reset_tracking_cache

    def remove_reward
        self.delay.award_tracking(-1, self.vote_topic_id)
    end
    
    def add_reward
        self.delay.award_tracking(1, self.vote_topic_id)
    end
    
    validates_uniqueness_of :vote_topic_id, :scope => :user_id

    def award_tracking pos, vote_topic_id
        vt = VoteTopic.find_for_tracking(vote_topic_id)
        vt.poster.award_points(Constants::TRACK_POINTS * pos)
    end

    def reset_tracking_cache
        Rails.cache.delete("vt_tracking_#{self.tracked_vote_topic.id}")
    end
    
    def increment_tracking_cache
        CacheUtil.increment("vt_tracking_#{self.tracked_vote_topic.id}", 1)
    end

    def decrement_tracking_cache
        CacheUtil.decrement("vt_tracking_#{self.tracked_vote_topic.id}", 1)
    end
end
