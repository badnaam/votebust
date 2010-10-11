class AddCommentLikesCount < ActiveRecord::Migration
  def self.up
      add_column :comments, :comment_likes_count, :integer, {:default => 0}
  end

  def self.down
      remove_column :comments, :comment_likes_count, :integer
  end
end
