# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def make_tooltip str
        #        return "<span class='tooltip'>#{str}</span>"
        return (render :partial => '/shared/tooltip', :locals => {:text => str})
    end

    def new_button_plain controller, txt
        if controller.class == VoteTopicsController && (controller.action_name == 'edit' || controller.action_name == 'new')
        elsif controller.class == UsersController && (controller.action_name == 'edit')
        else
            link_to(txt, new_user_posted_vote_topic_path(current_user), :id => 'main_new_vote_link',  :class=> 'special-text', :rel => "#vote_overlay")
        end
    end
    
    def new_button controller, txt
        str = ""
        if controller.class == VoteTopicsController && (controller.action_name == 'edit' || controller.action_name == 'new')
        elsif
            controller.class == UsersController && (controller.action_name == 'edit')
        else
            str << link_to(txt, new_user_posted_vote_topic_path(current_user), :id => 'main_new_vote_link',  :class=> 'special-text main-new-vote-link',
                :rel => "#vote_overlay")
        end
        return str
    end
    
    def cf key
        if (val = CACHE.fetch key).nil?
            if block_given?
                val = yield
            end
        end
        return val
    end

    def get_user_avatar user
        if !user.image_url.nil?
            return image_tag user.image_url, :class => 'profile-image', :alt => 'avataar'
        else
            return image_tag user.image.url(:small), :class=>'profile-image', :alt=>'avatar'
        end
    end
    
    def get_large_user_avatar user
        if !user.image_url.nil?
            return image_tag user.image_url, :class => 'profile-image-large', :alt => 'avataar'
        else
            return image_tag user.image.url(:large), :class=>'profile-image-large', :alt=>'avatar'
        end
    end

    def get_user_avatar_link user, anon=false
        if anon
            return image_tag Constants::MISSING_IMAGE_FILE, :class=> 'profile-image',:alt => 'avatar'
        else
            if !user.image_url.nil?
                return link_to(image_tag(user.image_url,:class=> 'profile-image',:alt => 'avatar'), user_path(user))
                #                return link_to "<img src=#{user.image_url} class='profile-image' alt='avatar'/>", user_path(user)
            else
                return link_to(image_tag(user.image.url(:small),:class=> 'profile-image',:alt => 'avatar'), user_path(user))
                #                return link_to "<img src=#{user.image.url(:small)} class='profile-image' alt='avatar'/>", user_path(user)
            end
        end
    end

    
    def select_options_tag(name='',select_options={},options={})
        #set selected from value
        selected = ''
        unless options[:value].blank?
            selected = options[:value]
            options.delete(:value)
        end
        select_tag(name,options_for_select(select_options,selected),options)
    end

    def page_title(title)
        content_for(:title) {title}
    end

    
    def reload_flash
        page.replace_html "flash_messages", :partial => 'layouts/flash_msg'
    end

end
