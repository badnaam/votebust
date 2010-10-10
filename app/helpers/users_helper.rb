module UsersHelper
    def headline user
        if current_user && current_user.id == user.id
            return  user.hdline.nil? ? "profile headline click to edit" : user.hdline
        else
             return user.hdline.nil? ? "" : user.hdline
        end
    end
    def status user
        if current_user && current_user.id == user.id
            return  user.status.nil? ? "Status click to edit" : user.status
        else
             return user.status.nil? ? "" : user.status
        end
    end
    def about user
        if current_user && current_user.id == user.id
            return  user.about.nil? ? "About you click to edit" : user.about
        else
             return user.about.nil? ? "" : user.about
        end
    end
end
