class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic

    validates_presence_of :body
    validates_length_of :body, :within => 1..Constants::MAX_COMMENT_LENGTH

    before_save :populate_option
    
    def populate_option
        vi = self.vote_topic.what_vi_user_voted_for(self.user)
        if !vi.nil?
            self.vi_option = vi.option
        else
            self.vi_option = Constants::OTHER_VI
        end
    end
end
