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
        self.follower.increment!(:trackings_count, pos)
    end

    def reset_tracking_cache
        Rails.cache.delete("vt_trackings_#{self.vote_topic_id}")
        Rails.cache.delete("vt_trackings_#{self.vote_topic_id}_hash")
    end
end
