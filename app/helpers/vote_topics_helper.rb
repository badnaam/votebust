module VoteTopicsHelper

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
            out << link_to_function("remove", "$(this).up('.#{fields.object.class.name.underscore}').hide(); $(this).previous().value = '1'")
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

    def get_vote_percent(v, total_votes)
        votes = v.votes_for
        if votes == 0
            return "#{v.option} - 0%"
        elsif total_votes == 0
            return 'N/A'
        else
            return "#{v.option} - #{votes} votes - #{sprintf('%.1f', ((votes.to_f / total_votes.to_f) * 100))}%"
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

    def get_sex_graph(v, vid)
        path = File.join(Constants::GRAPH_ASSET_DIR, "#{vid}", "#{v.id}#{Constants::SEX_GRAPH_POST_FIX}")
        check_path = File.join(Constants::GRAPHS_PATH, vid.to_s, v.id.to_s + Constants::SEX_GRAPH_POST_FIX)
        if File.exists?(check_path)
            return path
        else
            return nil
        end
    end

    def get_other_graphs(v)
        dir = File.join(Constants::GRAPHS_PATH, "#{v.id}")
        files = (Dir.foreach(dir).select{|f| (File.basename(f)).index('pie').nil? && !File.directory?(f)}).map {|x| File.join(Constants::GRAPH_ASSET_DIR, "#{v.id}", x)}

        return files
    end
    
    def get_main_graph(v)
        path = File.join(Constants::GRAPH_ASSET_DIR, "#{v.id}", "#{v.id}#{Constants::MAIN_GRAPH_POST_FIX}")
        check_path = File.join(Constants::GRAPHS_PATH, v.id.to_s, v.id.to_s + Constants::MAIN_GRAPH_POST_FIX)
        if File.exists?(check_path)
            return path
        else
            return nil
        end
    end
end
