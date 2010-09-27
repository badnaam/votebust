module VoteTopicsHelper

    def status_str str
        if str == VoteTopic::STATUS[:approved]
            "Approved"
        elsif str == VoteTopic::STATUS[:nw]
            "Waiting Moderator Approval"
        elsif str == VoteTopic::STATUS[:revised]
            "Waiting Moderator Approval"
        elsif str == VoteTopic::STATUS[:denied]
            "Not Approved"
        end
    end
    def order_links current_order
        orders = ["recent", "votes", "featured", "distance"]
        str = "<div><span class='go-right order-link' id=''>"
        orders.each do |o|
            if current_order == o
                str  << "<span class= 'current o-link'>#{current_order.titleize}</span>"
            else
                str << (link_to o.titleize, vote_topics_path(request.parameters.merge({'order', o})) , :class => 'order-link o-link')
            end
        end
        return (str << ('</span></div>'))
    end
    
    def flags v
        if v.flags.nil?
            return nil
        else
            a = v.flags.split(',')
            str = ""
            if a.include?('featured')
                str.concat(power_points v)
            end
            if a.include?('most_voted')
                str.concat("<span class='flag-wrapper t-trigger bld'>V</span>").concat("<span class='tooltip'>
                Highly voted</span>")
            end
            if a.include?('most_tracked')
                str.concat("<span class='flag-wrapper t-trigger bld'>T</span>").concat("<span class='tooltip'>
                Highly tracked</span>")
            end
            str.concat('</span>')
        end
    end
    
    def get_more_listing_str_vt listing_type
        if ["local", "most_tracked", "top", "featured", "tracked"].include?(listing_type)
            case listing_type
            when "local"
                listing_str = "All Local"
            when "most_tracked"
                listing_str = "More Most Tracked"
            when "top"
                listing_str = "More Most Voted"
            when "featured"
                listing_str = "All Featured"
            when "tracked"
                listing_str = "All Tracked"
            end
        else
            listing_str = "More"
        end
        return listing_str
    end

    def get_listing_str params
        if params[:category_id]
            listing_str = "In #{params[:category_id].titleize}"
        elsif params[:city]
            listing_str = "Topics in #{params[:city]}"
        elsif params[:state]
            listing_str = "Topics in #{params[:state]}"
        else
            case params[:listing_type]
            when "most_tracked_all"
                listing_str = "Most Tracked"
            when "top_all"
                listing_str = "Most Voted"
            when "featured_all"
                listing_str = "Featured"
            when "tracked_all"
                listing_str = "Topics you are tracking"
            else
                listing_str = "All"
            end
        end
    end

    
    def power_points vt
        if !vt.power_offered.nil? && vt.power_offered > 10
            points = vt.power_offered / 10
            return "<span class='flag-wrapper t-trigger'>
                        <span class='bld power-points'>#{points} </span>
                    </span>
                    <span class='tooltip'>Earn #{points} Voting Power for voting on this topic.<a href = '#' class='clearfix'>What's Voting Power?</a></span>"
        end
        return ""
    end
    
    def get_percent_div percent
        if percent == 0
            return nil
        else
            return "<li id= 'indicator' class='indicator-list'><div id = 'div_indicator' class='ui-corner-all indicator-div' style='width:#{percent}%;'>
            </div></li>"
        end
    end
    
    def get_facet_message key, opt, locations=nil
        fkeys = VoteTopic::FACET_KEYS
        if ['m', 'w', 'ag1','ag2', 'ag3', 'ag4', 'vl' ].include?(key)
            fkeys[key].gsub('<option>', opt)
        elsif ['wl', 'll'].include?(key)
            arr = opt.split('$$')
            fkeys[key].gsub('<option>', arr[0]).gsub('<states>', arr[1]).gsub('<cities>', arr[2])
        elsif ['dag'].include?(key)
            fkeys[key].gsub('<thing>', opt)
        end
    end

    def print_facet facet
        str = ""
        if !facet.m.nil?
            str << "<li>#{get_facet_message 'm', facet.m}</li>"
        end
        if !facet.w.nil?
            str << "<li>#{get_facet_message 'w', facet.w}</li>"
        end
        if !facet.dag.nil?
            str << "<li>#{get_facet_message 'dag', facet.dag}</li>"
        end
        if !facet.vl.nil?
            str << "<li>#{get_facet_message 'vl', facet.vl}</li>"
        end
        if !facet.wl.nil?
            str << "<li>#{get_facet_message 'wl', facet.wl}</li>"
        end
        if !facet.ll.nil?
            str << "<li>#{get_facet_message 'll', facet.ll}</li>"
        end
        if !facet.ag1.nil?
            str << "<li>#{get_facet_message 'ag1', facet.ag1}</li>"
        end
        if !facet.ag2.nil?
            str << "<li>#{get_facet_message 'ag2', facet.ag2}</li>"
        end
        if !facet.ag3.nil?
            str << "<li>#{get_facet_message 'ag3', facet.ag3}</li>"
        end
        if !facet.ag4.nil?
            str << "<li>#{get_facet_message 'ag4', facet.ag4}</li>"
        end
        return str
    end
    
    
    def js(data)
        if data.respond_to? :to_json
            data.to_json
        else
            data.inspect.to_json
        end
    end

    
    
    
    #    def get_vote_percent(v, total_votes)
    #        if v.votes_count == 0
    #            return "#{v.option.titleize} - 0%"
    #        elsif total_votes == 0
    #            return "#{v.option.titleize} - 0%"
    #        else
    #            return "#{v.option.titleize} - #{v.votes_count} votes - #{number_to_percentage((v.votes_count.to_f / total_votes.to_f) * 100, :precision => 2)}"
    #        end
    #    end
    #
    def get_vote_percent(v, total_votes)
        if v.votes_count  > 0 && total_votes > 0
            return "#{v.option.titleize} - #{v.votes_count} votes - #{number_to_percentage((v.votes_count.to_f / total_votes.to_f) * 100, :precision => 2)}"
        else
            return "#{v.option.titleize}"
        end
    end


    def add_object_link(name, form, object, partial, where)
        options = Hash.new
        options = {:parent => true}.merge(options)
        html = render(:partial => partial, :locals => { :f => form, :vote_item => object})
        link_to_function name, %{
if ($('.vote_item').length < 5) {
var new_object_id = new Date().getTime() ;
var html = $(#{js html}.replace(/index_to_replace_with_js/g, new_object_id)).hide();
        html.appendTo($("#{where}")).slideDown('slow');
} 
        }, :class => "add-option"
    end

    def js(data)
        if data.respond_to? :to_json
            data.to_json
        else
            data.inspect.to_json
        end
    end

    def remove_link_unless_new_record(fields)
        unless fields.object.new_record?
            out = ''
            out << fields.hidden_field(:_delete)
            out << link_to_function("Remove", "$(this).parent('.#{fields.object.class.name.underscore}').hide(); $(this).prev().val('1')")
            out
        end
    end
end
