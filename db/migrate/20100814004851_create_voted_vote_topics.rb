class CreateVotedVoteTopics < ActiveRecord::Migration
  def self.up
    create_table :voted_vote_topics do |t|
      t.integer :user_id
      t.references :user, :vote_topic
      t.timestamps
    end
  end

  def self.down
    drop_table :voted_vote_topics
  end
end
