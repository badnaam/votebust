class AddTotalVotesToVoteTopics < ActiveRecord::Migration
  def self.up
    add_column :vote_topics, :total_votes, :integer
  end

  def self.down
    remove_column :vote_topics, :total_votes
  end
end
