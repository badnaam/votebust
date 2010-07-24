class Vote < ActiveRecord::Base

    named_scope :for_voter,    lambda { |*args| {:conditions => ["voter_id = ? AND voter_type = ?", args.first.id, args.first.type.name]} }
    named_scope :for_voteable, lambda { |*args| {:conditions => ["voteable_id = ? AND voteable_type = ?", args.first.id, args.first.type.name]} }
    named_scope :recent,       lambda { |*args| {:conditions => ["created_at > ?", (args.first || 2.weeks.ago).to_s(:db)]} }
    named_scope :descending, :order => "created_at DESC"

    # NOTE: Votes belong to the "voteable" interface, and also to voters
    belongs_to :voteable, :polymorphic => true
    belongs_to :voter, :polymorphic => true

  
    attr_accessible :vote, :voter, :voteable

#    after_save :increment_votes
#    after_destroy :decrement_votes

    def increment_votes
        voter = self.voter
        voteable = self.voteable
        (voteable.vote_topic).post_process(voteable, voter, true)
    end
    
    def decrement_votes
        voter = self.voter
        voteable = self.voteable
        (voteable.vote_topic).post_process(voteable, voter, false)
    end
    # Uncomment this to limit users to a single vote on each item.
    # validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id]

end