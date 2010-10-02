class AddIndexToVoteTopics < ActiveRecord::Migration
  def self.up
    add_column :vote_topics, :anon, :boolean
     add_index :vote_topics, :status
     add_index :vote_topics, :user_id

  end

  def self.down
    remove_column :vote_topics, :anon
  end
end
