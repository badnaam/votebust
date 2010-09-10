module VoteTopicsHelper

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
                str.concat("<span class='ui-icon ui-icon-star most-voted'></span>").concat("<span class='tooltip'>
                Highly voted</span>")
            end
            if a.include?('most_tracked')
                str.concat("<span class='ui-icon ui-icon-copy most-tracked'></span>").concat("<span class='tooltip'>
                Highly tracked</span>")
            end
            str.concat('</span>')
        end
    end
    
    def get_more_listing_str listing_type
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

    def get_listing_str listing_type, context
        case listing_type
        when "category"
            listing_str = "In #{context}"
        when "tracked_all"
            listing_str = "Tracked"
        when "local_all"
            listing_str = "In #{context}"
        when "top_all"
            listing_str = "Most Voted"
        when "featured_all"
            listing_str = "All Featured"
        when "featured_all"
            listing_str = "Featured"
        else
            listing_str = "All"
        end
        return listing_str
    end

    
    def power_points vt
        if !vt.power_offered.nil? && vt.power_offered > 10
            points = vt.power_offered / 10
            return "<span class='power-wrapper'>
                        <span class='ui-icon ui-icon-power'></span>
                        <span class='go-left bld power-points'>#{points} </span>
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
end
