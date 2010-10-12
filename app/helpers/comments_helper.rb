module CommentsHelper
    def like comment, user_likes_it
        likes_count = comment.comment_likes_count
        if likes_count > 0
            if user_likes_it
                if likes_count > 1
                    return "<span class='left-mar small bld'>You and " + (likes_count - 1).to_s + " others like this.</span>"
                else
                    return "<span class='left-mar small bld'>You like this.</span>"
                end
            else
                return "<span class='left-mar small bld'>" + likes_count.to_s  + " people like this.</span>"
            end
        end
    end
end
