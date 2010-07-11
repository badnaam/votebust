class CreateVoteTopics < ActiveRecord::Migration
  def self.up
    create_table :vote_topics do |t|
      t.string :topic
      t.string :status
      t.datetime :published_at

      t.timestamps
      t.belongs_to :user
     
    end
  end

  def self.down
    drop_table :vote_topics
  end
end
