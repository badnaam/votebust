class AddSexVotesToVoteItem < ActiveRecord::Migration
  def self.up
    add_column :vote_items, :male_votes, :integer
    add_column :vote_items, :female_votes, :integer
  end

  def self.down
    remove_column :vote_items, :female_votes
    remove_column :vote_items, :male_votes
  end
end
