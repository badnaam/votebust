module VoteTopicsHelper

    def get_percent_div percent, color
        if percent == 0
            return ""
        else
            return "<li class='ui-corner-all' style='width:#{percent}%; background-color:#{color};height:12px'>&nbsp;</li>"
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
    
    def add_object_link(name, form, object, partial, where)
        options = Hash.new
        options = {:parent => true}.merge(options)
        html = render(:partial => partial, :locals => { :f => form, :vote_item => object})
        link_to_function name, %{
      var new_object_id = new Date().getTime() ;
      var html = $(#{js html}.replace(/index_to_replace_with_js/g, new_object_id)).hide();
      html.appendTo($("#{where}")).slideDown('slow');
        }
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
            out << link_to_function("remove", "$(this).parent('.#{fields.object.class.name.underscore}').hide(); $(this).prev().value = '1'")
            out
        end
    end

    # These use the current date, but they could be lots easier.
    # Maybe just keep a global counter which starts at 10 or so.
    # That would be good enough if we only build 1 new record in the controller.
    #
    # And this of course is only needed because Ryan's example uses JS to add new
    # records. If you just build a new one in the controller this is all unnecessary.

    def add_task_link(name, form)
        link_to_function name do |page|
            task = render(:partial => 'task', :locals => { :pf => form, :task => Task.new })
            page << %{var new_task_id = "new_" + new Date().getTime();$('tasks').insert({ bottom: "#{ escape_javascript task }".replace(/new_\\d+/g, new_task_id) });
            }
        end
    end

    #    def get_vote_percent(v, total_votes)
    #        votes = v.votes_for
    #        if votes == 0
    #            return "#{v.option} - 0%"
    #        elsif total_votes == 0
    #            return 'N/A'
    #        else
    #            return "#{v.option.titleize} - #{votes} votes - #{number_to_percentage((votes.to_f / total_votes.to_f) * 100, :precision => 2)}"
    #        end
    #    end
    def get_vote_percent(v, total_votes)
        #        votes = v.votes_count
        votes = v.votes.size
        if votes == 0
            return "#{v.option} - 0%"
        elsif total_votes == 0
            return "#{v.option} - 0%"
        else
            return "#{v.option.titleize} - #{votes} votes - #{number_to_percentage((votes.to_f / total_votes.to_f) * 100, :precision => 2)}"
        end
    end
    
    def add_vi_link(name, form)
        link_to_function name do |page|
            vote_item = render(:partial => 'vi', :locals => { :f => form, :vote_item => VoteItem.new })
            page << %{var new_vote_item_id = "new_" + new Date().getTime();$('vote_items').insert({ bottom: "#{ escape_javascript vote_item }".
            replace(/new_\\d+/g, new_vote_item_id) });
            }
        end
    end

    def add_tag_link(name, form)
        link_to_function name do |page|
            tag = render(:partial => 'tag', :locals => { :pf => form, :tag => Tag.new })
            page << %{var new_tag_id = "new_" + new Date().getTime();$('tags').insert({ bottom: "#{ escape_javascript tag }".replace(/new_\\d+/g, new_tag_id) });}
        end
    end
end
