class AddIndexToComments < ActiveRecord::Migration
  def self.up
      add_index :comments, :vote_item_id
  end

  def self.down
      remove_index :comments, :vote_item_id
  end
end
