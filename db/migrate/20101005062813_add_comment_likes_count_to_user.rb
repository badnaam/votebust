class AddCommentLikesCountToUser < ActiveRecord::Migration
  def self.up
      add_column :users, :comment_likes_count, :integer
      add_index :users, :comment_likes_count
  end

  def self.down
      remove_column :users, :comment_likes_count
      remove_index :users, :comment_likes_count
  end
end
