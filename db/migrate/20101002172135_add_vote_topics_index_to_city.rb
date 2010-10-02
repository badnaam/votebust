class AddVoteTopicsIndexToCity < ActiveRecord::Migration
  def self.up
      add_index :cities, :vote_topics_count
  end

  def self.down
  end
end
