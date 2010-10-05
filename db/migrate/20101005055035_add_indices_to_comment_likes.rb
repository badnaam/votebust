class AddIndicesToCommentLikes < ActiveRecord::Migration
  def self.up
      add_index :comment_likes, :comment_id
      add_index :comment_likes, :user_id
  end

  def self.down
  end
end
