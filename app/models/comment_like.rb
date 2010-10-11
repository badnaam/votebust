class CommentLike < ActiveRecord::Base
    belongs_to :comment, :counter_cache => true
    belongs_to :user, :counter_cache => true
    has_many :comment_likes
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
            Rails.cache.delete("user_comment_like_count_#{c.user.id}")
        end
    end

    def self.liked_by? user, comment_id
        arr = Rails.cache.fetch("user_comment_like_#{user.id}_#{user.comment_likes_count}") do
            user.comment_likes.map(&:comment_id)
        end
        return arr.include?(comment_id)
    end

    #the likes count for the poster of the comment
    def self.likes_count_for_comment_poster id
        Rails.cache.fetch("user_comment_like_count_#{id}") do
            sql = "SELECT count(*) as c FROM `comment_likes` INNER JOIN comments ON comments.id = comment_likes.comment_id WHERE (comments.user_id = " + id.to_s + ")"
            CommentLike.find_by_sql(sql).first.c
        end
    end
end
