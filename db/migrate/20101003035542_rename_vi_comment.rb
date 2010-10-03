class RenameViComment < ActiveRecord::Migration
  def self.up
      rename_column :comments, :vi_id, :vote_item_id
      add_index :vote_items, :comments_count
  end

  def self.down
      rename_column :comments, :vote_item_id, :vi_id
      remove_index :vote_items, :comments_count
  end
end
