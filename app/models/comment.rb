class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic

    validates_presence_of :body, :vote_topic_id, :user_id
    validates_length_of :body, :within => 1..Constants::MAX_COMMENT_LENGTH

#    before_save :populate_option

    def self.do_comment body, vt_id, vi_id, user_id
        v = create(:body => body, :vote_topic_id => vt_id, :vi_id => vi_id, :user_id => user_id)
        if v && v.valid?
            return v
        else
            return nil
        end
    end
    
    def populate_option
        vi = self.vote_topic.what_vi_user_voted_for(self.user)
        if !vi.nil?
            self.vi_option = vi.option
        else
            self.vi_option = Constants::OTHER_VI
        end
    end
end
