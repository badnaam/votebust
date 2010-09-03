class Vote < ActiveRecord::Base
    belongs_to :user, :counter_cache => true
    belongs_to :vote_item, :counter_cache => true
    belongs_to :vote_topic, :counter_cache => true

    validates_uniqueness_of :user_id, :scope => [:vote_topic_id], :message => "You have already voted."
    
    acts_as_mappable
    #    attr_accessible :vote, :voter, :voteable
    def self.get_voted_vote_topics user_id, limit, page
        if limit
            coll = find(:all, :conditions => ['votes.user_id = ?', user_id],  :order => 'vote_topics.trackings_count DESC',
                :include => [{:vote_topic => [:vote_items, :poster, :category]}], :limit => Constants::SMART_COL_LIMIT,
                :select => Constants::VOTE_TOPIC_FIELDS)
        else
            coll = paginate( :conditions => ['votes.user_id = ?', user_id], :order => 'vote_topics.trackings_count DESC',
                :include => [{:vote_topic => [{:vote_items => :votes}, :poster, :category]}], :per_page => Constants::LISTINGS_PER_PAGE,
                :page => page, :select => Constants::VOTE_TOPIC_FIELDS)
        end
    end
end
