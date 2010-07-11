class CreateVoteItems < ActiveRecord::Migration
  def self.up
    create_table :vote_items do |t|
      t.string :option
      t.string :info

      t.timestamps
      t.belongs_to :vote_topic
    end
  end

  def self.down
    drop_table :vote_items
  end
end
