class AddCommentsCountToVoteItem < ActiveRecord::Migration
  def self.up
      add_column :vote_items, :comments_count, :integer, {:default => 0, :null => true}
  end

  def self.down
      remove_column :vote_items, :comments_count
  end
end
