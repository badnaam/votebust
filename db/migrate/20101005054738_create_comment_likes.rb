class CreateCommentLikes < ActiveRecord::Migration
  def self.up
    create_table :comment_likes do |t|

      t.references :comment
      t.references :user
      t.index :comment_id
      t.index :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :comment_likes
  end
end
