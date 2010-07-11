class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic

    
end
