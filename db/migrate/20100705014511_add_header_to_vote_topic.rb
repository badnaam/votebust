class AddHeaderToVoteTopic < ActiveRecord::Migration
  def self.up
    add_column :vote_topics, :header, :string
  end

  def self.down
    remove_column :vote_topics, :header
  end
end
