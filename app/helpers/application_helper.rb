# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def sort_vote_items (vote_items)
        arr = Array.new
        vote_items.sort_by {|vi| vi.votes.size}.reverse_each do |vi|
            arr << vi
        end
        return arr
    end
    
    def missing_user_image?(user)
        if user.processing == true
            return true
        else
            return false
        end
    end

    def get_user_icon_only(user)
        if !missing_user_image?(user)
            return image_tag user.image.url(:small), :class => 'profile-image'
        else
            return image_tag Constants::MISSING_IMAGE_FILE,:class => 'profile-image'
        end
    end
    
    def get_user_icon (user)
        if !missing_user_image?(user)
            if current_user
                return link_to((image_tag (user.image.url(:small))), user, :class => 'profile-image')
            else
                return image_tag user.image.url(:small), :class => 'profile-image'
            end
        else
            if current_user
                return link_to((image_tag (Constants::MISSING_IMAGE_FILE)), user, :class => 'profile-image')
            else
                return image_tag Constants::MISSING_IMAGE_FILE,:class => 'profile-image'
            end
        end
    end

    
    def get_user_icon_image_link (user)
        if !missing_user_image?(user)
            if current_user
                return '<li>' + (link_to (image_tag user.image.url(:small)), user, :class => 'profile-image') + '</li><li>' +
                  (link_to user.username, user, :class => 'user-profile-link') + '</li>'
            else
                return '<li>' + (image_tag user.image.url(:small), :class => 'profile-image') + '</li><li>' + "#{user.username} (#{user.votes.count}) votes"  + '</li>'
            end
        else
            if current_user
                return '<li>' + (link_to (image_tag Constants::MISSING_IMAGE_FILE), user, :class => 'profile-image') + '</li><li>' +
                  (link_to user.username, user, :class => 'user-profile-link') + '</li>'
            else
                return '<li>' + (image_tag Constants::MISSING_IMAGE_FILE,:class => 'profile-image') + '</li><li>' +  "#{user.username} (#{user.votes.count}) votes"  + '</li>'
            end
        end
    end

    
    def get_user_profile_link user
        if current_user
            
        else
            "<span class='user-profile-text'>#{user.username}</span>"
        end
    end
    
    def color_link_with_icon(id, href, icon, text)
        return "<a id= '#{id}' class='ui-state-default ui-corner-all link-with-icon' href='#{href}'><span class='ui-icon #{icon}'></span>#{text}</a>"
    end

    def plain_link_with_icon(id, href, icon, text)
        return "<a id= '#{id}' href='#{href}' class='link-with-icon'><span class='ui-icon #{icon}'></span>#{text}</a>"
    end
    def text_with_icon(icon, text)
        return "<div><span class='link-with-icon'><span class='ui-icon #{icon}'></span>#{text}</div>"
    end

    def inline_text_with_icon(icon, text)
        return "<span class='link-with-icon'><span class='ui-icon #{icon}'></span>#{text}"
    end

    def icon_header(element, icon_class, icon, text)
        return " <#{element}  class='#{icon_class} #{icon} icon-header'>#{text} </#{element}>"
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

    def generate_html(form_builder, method, options = {})
        options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
        options[:partial] ||= method.to_s.singularize
        options[:form_builder_local] ||= :f

        form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
            render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
        end
    end

    def link_to_new_nested_form(name, form_builder, method, options = {})
        options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
        options[:partial] ||= method.to_s.singularize
        options[:form_builder_local] ||= :f
        options[:element_id] ||= method.to_s
        options[:position] ||= :bottom
        options[:max] ||= 2
        options[:input_type] ||= "text"
        link_to_function name, :id => options[:id] do |page|
            html = generate_html(form_builder,
                method,
                :object => options[:object],
                :partial => options[:partial],
                :form_builder_local => options[:form_builder_local]
            )
            page << %{
        $('#{options[:element_id]}').insert({ #{options[:position]}: "#{ escape_javascript html }".replace(/NEW_RECORD/g, new Date().getTime()) });
            }
            page << %{num = $$("##{options[:element_id]} input[type='#{options[:input_type]}']").length;}
            page << %{
                if(num >= #{options[:max]}) {
                    $("#{options[:id]}").hide();
                }
            }
        end
    end

end
