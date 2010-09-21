module SearchesHelper
    def order_links_s current_order
        orders = Constants::SEARCH_SORT_ORDERS
        #no distance ordering for term and state search
        (orders = orders - "distance".to_a) if (request.parameters[:q] || request.parameters[:state])
        str = "<div><span class='go-right order-link' id=''>"
        orders.each do |o|
            if current_order == o
                str  << "<span class= 'current'>#{current_order.titleize}</span>"
            else
                if request.parameters[:city]
                    str << (link_to o.titleize, city_vote_topics_path(request.parameters.merge({'order', o})) , :class => 'order-link')
                elsif request.parameters[:state]
                    str << (link_to o.titleize, state_vote_topics_path(request.parameters.merge({'order', o})) , :class => 'order-link')
                elsif request.parameters[:q]
                    str << (link_to o.titleize, searches_path(request.parameters.merge({'order'=> o})) , :class => 'order-link')
                end
            end
        end
        return (str << ('</span></div>'))
    end
    
    def get_search_context params
        if params[:city]
            return "Vote Topics in &quot; #{params[:city]} &quot;"
        elsif params[:state]
            return "Vote Topics in &quot; #{params[:state]} &quot;"
        elsif params[:q]
            return "Results for &quot; #{params[:q]} &quot;"
        else
            "All"
        end
    end

    def get_more_listing_str params
        str = "<div class='append-bottom'>"
        if params[:city]
            str << link_to("More in #{params[:city]}", city_vote_topics_path(params[:city], :order => 'distance'), :class => "bld go-right bottom-mar")
        elsif params[:state]
            str << link_to("More in #{params[:state]}", state_vote_topics_path(params[:state], :order => 'distance'), :class => "bld go-right bottom-mar")
        end
        str << "</div>"
    end
end

