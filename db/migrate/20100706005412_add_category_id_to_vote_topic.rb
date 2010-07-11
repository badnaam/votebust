class AddCategoryIdToVoteTopic < ActiveRecord::Migration
  def self.up
    add_column :vote_topics, :category_id, :integer
  end

  def self.down
    remove_column :vote_topics, :category_id
  end
end
