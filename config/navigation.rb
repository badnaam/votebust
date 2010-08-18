# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
    # Specify a custom renderer if needed.
    # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
    # The renderer can also be specified as option in the render_navigation call.
    # navigation.renderer = Your::Custom::Renderer

    # Specify the class that will be applied to active navigation items. Defaults to 'selected'
    # navigation.selected_class = 'your_selected_class'

    # Item keys are normally added to list items as id.
    # This setting turns that off
    # navigation.autogenerate_item_ids = false

    # You can override the default logic that is used to autogenerate the item ids.
    # To do this, define a Proc which takes the key of the current item as argument.
    # The example below would add a prefix to each key.
    # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

    # The auto highlight feature is turned on by default.
    # This turns it off globally (for the whole plugin)
    # navigation.auto_highlight = false

    # Define the primary navigation
    navigation.items do |primary|
        # Add an item to the primary navigation. The following params apply:
        # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
        # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
        # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
        # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
        #
        primary.item :home_nav, 'New', root_path do|n| 

        end
        primary.item :cat_nav, 'Categories', "#" do|ct|
            if !@category.nil? && !@vote_topics.nil?
                ct.item :ct_vt_index, @category.name, category_vote_topics_path(@category, :listing_type => "category")
            end
        end
        primary.item :vote_nav, 'Votes', vote_topics_path do|v|
            if @vote_topic && !@vote_topic.id.nil? 
                v.item :v_show, @vote_topic.header,vote_topic_path(@vote_topic)
            end
        end
#        primary.item :profile_nav, 'Profile', user_path(current_user), :if => Proc.new {!current_user.nil?} do|a|
#            if current_user
#                a.item :u_edit, "Edit Profile", edit_user_path(current_user)
#            end
#        end

        #    primary.item :account_nav, "Account", gaccount_path, :if => Proc.new {current_user}

        # Add an item which has a sub navigation (same params, but with block)
        #    primary.item :key_2, 'name', url, options do |sub_nav|
        # Add an item to the sub navigation (same params again)
        #      sub_nav.item :key_2_1, 'name', url, options
        #    end

        # You can also specify a condition-proc that needs to be fullfilled to display an item.
        # Conditions are part of the options. They are evaluated in the context of the views,
        # thus you can use all the methods and vars you have available in the views.
        #    primary.item :key_3, 'Admin', url, :class => 'special', :if => Proc.new { current_user.admin? }
        #    primary.item :key_4, 'Account', url, :unless => Proc.new { logged_in? }

        # you can also specify a css id or class to attach to this particular level
        # works for all levels of the menu
        # primary.dom_id = 'menu-id'
        # primary.dom_class = 'menu-class'

        # You can turn off auto highlighting for a specific level
        # primary.auto_highlight = false

    end
end