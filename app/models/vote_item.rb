class VoteItem < ActiveRecord::Base
    belongs_to :vote_topic
    acts_as_voteable
    after_update :destroy_if_option_blank

    def destroy_if_option_blank
        if self.option.blank?
            self.destroy
        end
    end


    def get_vote_percent_num(total_votes)
        votes = self.votes_for
        if votes == 0
            return 0
        elsif total_votes == 0
            return 0
        else
            return ((votes.to_f / total_votes.to_f) * 100).to_f
        end
    end

    def reset_counters
        self.update_attribute(:male_votes, 0)
        self.update_attribute(:female_votes, 0)
        self.update_attribute(:ag_1_v, 0)
        self.update_attribute(:ag_2_v, 0)
        self.update_attribute(:ag_3_v, 0)
        self.update_attribute(:ag_4_v, 0)
    end
end
