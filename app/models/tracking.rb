class Tracking < ActiveRecord::Base
    belongs_to :follower, :class_name => "User", :foreign_key => :user_id
    belongs_to :tracked_vote_topic, :class_name => "VoteTopic", :foreign_key => :vote_topic_id, :counter_cache => true
    
    validates_uniqueness_of :vote_topic_id, :scope => :user_id

end
