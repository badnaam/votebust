class VotedVoteTopic < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic
    validates_uniqueness_of :user_id, :scope => :vote_topic_id

    def self.get_voted_vote_topics user_id, limit, page
        if limit
            coll = find(:all, :conditions => ['voted_vote_topics.user_id = ?', user_id],  :order => 'vote_topics.trackings_count DESC',
                :include => [{:vote_topic => [{:vote_items => :votes}, :poster, :category]}], :limit => Constants::SMART_COL_LIMIT,
                :select => ' vote_topics.id, vote_topics.header, vote_topics.topic, vote_topics.user_id, vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes,
                 categories.id, categories.name, vote_topics.anon, users.id, users.username, vote_items.option, vote_items.v_count, vote_topics.trackings_count, users.city,
                users.state, users.zip')
        else
            coll = paginate( :conditions => ['voted_vote_topics.user_id = ?', user_id], :order => 'vote_topics.trackings_count DESC',
                :include => [{:vote_topic => [{:vote_items => :votes}, :poster, :category]}], :per_page => Constants::LISTINGS_PER_PAGE,
                :page => page, :select => ' vote_topics.id, vote_topics.header, vote_topics.topic, vote_topics.user_id, vote_topics.category_id, vote_topics.created_at,
                vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id, users.username,vote_items.option,  vote_items.v_count,
                vote_topics.trackings_count, users.city, users.state, users.zip')
        end
    end
end
