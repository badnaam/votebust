class Tracking < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic
    validates_uniqueness_of :vote_topic_id, :scope => :user_id
end
