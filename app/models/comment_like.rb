class CommentLike < ActiveRecord::Base
    belongs_to :comment
    belongs_to :user, :counter_cache => true
    validates_uniqueness_of :user_id, :scope => :comment_id, :message => "You have already liked this comment"

    after_create :create_comment_like
    after_destroy :destroy_comment_like

    def create_comment_like
        CommentLike.delay.comment_liked self.comment.id, self, 1
    end
    def destroy_comment_like
        CommentLike.delay.comment_liked self.comment.id, self, -1
    end

    def self.comment_liked cid, inst, add
       c = Comment.find(cid)
       if !c.nil?
           c.user.award_points(1 * add)
       end
#       inst.user.increment!(:comment_likes_count, add)
    end

    def self.liked_by? user, comment_id
        arr = Rails.cache.fetch("user_comment_like_#{user.id}_#{user.comment_likes_count}") do
            user.comment_likes.map(&:comment_id)
        end
        return arr.include?(comment_id)
    end
end
