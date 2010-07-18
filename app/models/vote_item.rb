class VoteItem < ActiveRecord::Base
    belongs_to :vote_topic
    acts_as_voteable

    def get_vote_percent(total_votes)
        votes = self.votes_for
        if votes == 0
            return "#{self.option} - 0%"
        elsif total_votes == 0
            return 'N/A'
        else
            return "#{self.option} - #{votes} votes - #{sprintf('%.1f', ((votes.to_f / total_votes.to_f) * 100))}%"
        end
    end

    def get_vote_percent_num(total_votes)
        votes = self.votes_for
        if votes == 0
            return 0
        elsif total_votes == 0
            return 0
        else
            return ("%2.2f" % (votes.to_f / total_votes.to_f) * 100).to_f
        end
    end
end
