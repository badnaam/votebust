class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic

    validates_presence_of :body
    validates_length_of :body, :within => 1..Constants::MAX_COMMENT_LENGTH
    
end
