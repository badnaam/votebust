require 'rubygems'
require 'gruff'
include ActionView::Helpers::TextHelper

class VoteTopic < ActiveRecord::Base
    belongs_to :user
    belongs_to :category
    has_many :comments
    has_many :vote_items, :dependent => :destroy

    #\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b
    validates_presence_of :topic
    validates_length_of :header, :maximum => Constants::MAX_VOTE_TOPIC_HEADER, :allow_nil => true
    validates_length_of :friend_emails, :maximum => Constants::MAX_VOTE_TOPIC_FEMAILS, :allow_nil => true
    validate :valid_email?
    validate :min_vote_items, :if => :its_new?
    accepts_nested_attributes_for :vote_items, :limit => 5, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:option].blank? }

    after_destroy :destroy_graphs
    attr_accessible :topic, :header, :vote_items_attributes, :cached_slug, :friend_emails, :anon, :header, :category_id
    has_friendly_id :topic, :use_slug => true, :approximate_ascii => true, :max_length => 50, :cache_column => :cached_slug
    #    acts_as_mappable :through => :merchant

    #    scope_procedure :latest, lambda {created_at_gte(p[0]).created_at_lt(p[1]) }
    scope_procedure :latest, lambda {created_at_gte(Constants::SMART_COL_LATEST_LIMIT.ago) }

    
    def valid_email?
        if !self.friend_emails.nil?
            emails = self.friend_emails.split(",")
            emails.each do |email|
                if Authlogic::Regex.email.match(email.strip).nil?
                    errors.add(:friend_emails, "Invalid email address")
                    return false
                end
            end
        end
    end

    
    define_index do
        indexes :header
        indexes :topic
        indexes vote_items.option, :as => :option

        has created_at, updated_at, :total_votes
    end

    def destroy_graphs
        path = File.join(Constants::GRAPHS_PATH, "#{self.id}")
        if File.exists?(path)
            FileUtils.rmdir path
        end
    rescue
        #Rescue code here
    end

    def deliver_new_vote_notification!
        Notifier.deliver_new_vote_notification(self)
    end
    
    def post_process(selected_response, user, add)
        if add == true
            inc = 1
        else
            inc = -1
        end

        self.increment!(:total_votes, inc)
        #update male/female
        if !user.sex.nil? && user.sex == 0
            selected_response.increment!(:male_votes, inc)
        else
            selected_response.decrement!(:female_votes, inc)
        end
        age = user.age
        if Constants::AGE_GROUP_1.include?(age)
            selected_response.increment!(:ag_1_v, inc)
        elsif Constants::AGE_GROUP_2.include?(age)
            selected_response.increment!(:ag_4_v, inc)
        elsif Constants::AGE_GROUP_3.include?(age)
            selected_response.increment!(:ag_3_v, inc)
        else
            selected_response.increment!(:ag_4_v, inc)
        end
        #        make_gender_graph_stacked(self)
        #        make_age_graph_stacked(self)
        #        make_pie_graph(self, self.vote_items)
    end
    
    def make_flash_gender_graph_stacked
        title = Title.new('By Gender')
        title.set_style( '{font-size: 12px; color: #F24062;font-weight: bold;font-family:Verdana; text-align: center;}' );
        bar_stack = BarStack.new
        vi = self.vote_items
        labels_arr = Array.new
        totals = Array.new

        vi.each do |vv|
            tv = vv.votes_for
            totals << tv
            male_val =  vv.male_votes
            female_val =  vv.female_votes
            
            bar_male = BarStackValue.new(male_val,'#C4D318')
            bar_female = BarStackValue.new(female_val,'#50284A')

            bar_stack.append_stack(Array.new([bar_male, bar_female]))
            labels_arr << XAxisLabel.new(truncate(vv.option, :length => Constants::GRAPH_X_LABEL_LENGTH, :omission => '~'),'#000000', 12, 0)
        end
        #Make keys
        keys_arr = Array.new
        keys_arr << BarStackKey.new('#C4D318', "Men", 10)
        keys_arr << BarStackKey.new('#50284A', "Women", 10)
        bar_stack.set_keys(keys_arr)
        
        #        bar_stack.set_tooltip('X label [#x_label#], Value [#val#]<br>Total [#total#]' )
        bar_stack.set_tooltip('#val# of #total#' )
        
        y = YAxis.new();
        n = (totals.sort{|x, z| z <=> x})[0]
        y.set_range( 0, n, (n / 5).ceil);
        x = XAxis.new();

        x.labels = labels_arr
        
        x.set_colour('#ffffff')
        x.set_grid_colour('#ffffff')
        y.set_colour('#ffffff')
        y.set_grid_colour('#ffffff')

        x.set_labels_from_array(labels_arr);

        tooltip = Tooltip.new;
        tooltip.set_hover();
        chart = OpenFlashChart.new
        chart.bg_colour = "#ffffff"
        chart.set_title(title)
        chart.add_element(bar_stack)
        chart.x_axis = x ;
        chart.y_axis = y ;
        chart.set_tooltip( tooltip );
        return chart.to_s
    end

    def make_flash_age_graph_stacked
        title = Title.new"By Age Group"
        title.set_style( '{font-size: 12px; color: #F24062; text-align: center;}' );
        bar_stack = BarStack.new
        
        vi = self.vote_items
        labels_arr= Array.new
        totals = Array.new

        vi.each do |vv|
            totals << vv.votes_for
            ag1 =  vv.ag_1_v
            ag2 = vv.ag_2_v
            ag3 = vv.ag_3_v
            ag4 = vv.ag_4_v
            bar_stack.append_stack(Array.new([BarStackValue.new(ag1,'#C4D318'), 
                        BarStackValue.new(ag2,'#50284A'), BarStackValue.new(ag3,'#2AB597'), BarStackValue.new(ag4,'#B00E21')]))
            labels_arr << XAxisLabel.new(truncate(vv.option, :length => Constants::GRAPH_X_LABEL_LENGTH, :omission => '~'), '#000000', 12, 0)
        end
        #Make keys
        sag1 = "#{Constants::AGE_GROUP_1.first} - #{Constants::AGE_GROUP_1.last}"
        sag2 = "#{Constants::AGE_GROUP_2.first} - #{Constants::AGE_GROUP_2.last}"
        sag3 = "#{Constants::AGE_GROUP_3.first} - #{Constants::AGE_GROUP_3.last}"
        sag4 = "#{Constants::AGE_GROUP_4.first} - #{Constants::AGE_GROUP_4.last}"

        keys_arr = Array.new
        keys_arr << BarStackKey.new('#C4D318', sag1, 10)
        keys_arr << BarStackKey.new('#50284A', sag2, 10)
        keys_arr << BarStackKey.new('#2AB597', sag3, 10)
        keys_arr << BarStackKey.new('#B00E21', sag4, 10)
        bar_stack.set_keys(keys_arr)
        
        #        bar_stack.set_tooltip('X label [#x_label#], Value [#val#]<br>Total [#total#]' )
        bar_stack.set_tooltip('#val# of #total#' )

        y = YAxis.new();
        n = (totals.sort{|x, z| z <=> x})[0]
        y.set_range( 0, n, (n / 5).ceil);
        x = XAxis.new();
        x.labels = labels_arr

        x.set_colour('#ffffff')
        x.set_grid_colour('#ffffff')
        y.set_colour('#ffffff')
        y.set_grid_colour('#ffffff')
        
        tooltip = Tooltip.new;
        tooltip.set_hover();

        chart = OpenFlashChart.new
        chart.bg_colour = '#ffffff'
        chart.set_title(title)
        chart.add_element(bar_stack)

        chart.x_axis = x ;
        chart.y_axis = y ;
        chart.set_tooltip( tooltip );
        return chart.to_s
    end

    def make_flash_pie_graph(return_object)
        pie = Pie.new
        pie.start_angle = 35
        pie.animate = true
        pie.tooltip = '#val# of #total#<br>#percent# of 100%'
        pie.colours = ["#504F7D", "#68BC52", "#47703C", "#7E271B", "#BC7E5C"]

        total_votes = self.total_votes
        vals = Array.new
        vi = self.vote_items
        
        vals = Array.new
        vi.each do |x|
            vals << PieValue.new(x.votes_for, "#{x.option}")

        end
        pie.values = vals
        
        chart = OpenFlashChart.new
        chart.bg_colour = "#ffffff"
        chart.add_element(pie)
        chart.x_axis = nil
        if return_object
            return chart
        else
            return chart.to_s
        end
    end

    

    def what_user_voted_for(user)
        vi = self.vote_items
        if !vi.nil?
            vi.each do |v|
                if user.voted_for?(v)
                    return v.option
                end
            end
        end
    end

    def what_vi_user_voted_for(user)
        vi = self.vote_items
        if !vi.nil?
            vi.each do |v|
                if user.voted_for?(v)
                    return v
                end
            end
        end
    end
    

    def is_vote_complete?(vt, user)
        vote_complete = false
        vt.each do |v|
            if v.voted_by?(user)
                vote_complete = true
                break
            end
        end
        return vote_complete
    end
    
    def min_vote_items
        if self.vote_items.length < 2
            errors.add_to_base("Please specify at least two vote options")
            return false
        end
    end

    def its_new?
        self.new_record?
    end

    def deactivate_current_vote
        @existing_vote_topic = VoteTopic.find_by_status_and_user_id('a', self.user_id)
        if !@existing_vote_topic.nil?
            if !@existing_vote_topic.update_attribute(:status, 'd')
                return false
            else
                self.status = 'a'
            end
        else
            self.status = 'a'
        end
    end

    def make_age_graph_stacked(vt)
        g = Gruff::StackedBar.new(Constants::LARGE_GRAPH_DIM_16_9)
        g.title = "By Age Group"
        vi = vt.vote_items
        ag1_arr = Array.new
        ag2_arr = Array.new
        ag3_arr = Array.new
        ag4_arr = Array.new
        labels_hash = Hash.new

        vi.each_with_index do |vv, i|
            ag1_arr << (vv.ag_1_v.to_f / vv.votes_for.to_f) * 100 if vv.votes_for > 0
            ag2_arr << (vv.ag_2_v.to_f / vv.votes_for.to_f) * 100 if vv.votes_for > 0
            ag3_arr << (vv.ag_3_v.to_f / vv.votes_for.to_f) * 100 if vv.votes_for > 0
            ag4_arr << (vv.ag_4_v.to_f / vv.votes_for.to_f) * 100 if vv.votes_for > 0
            labels_hash[i] = truncate(vv.option, :length => 10, :omission => '~')
        end

        ag1 = "#{Constants::AGE_GROUP_1.first} - #{Constants::AGE_GROUP_1.last}"
        ag2 = "#{Constants::AGE_GROUP_2.first} - #{Constants::AGE_GROUP_2.last}"
        ag3 = "#{Constants::AGE_GROUP_3.first} - #{Constants::AGE_GROUP_3.last}"
        ag4 = "#{Constants::AGE_GROUP_4.first} - #{Constants::AGE_GROUP_4.last}"

        dataset = [[ag1, ag1_arr], [ag2, ag2_arr], [ag3, ag3_arr], [ag4, ag4_arr]]

        dataset.each do |data|
            g.data(data[0], data[1])
        end
        g.labels = labels_hash
        path = File.join(Constants::GRAPHS_PATH, "#{vt.id}")
        if !File.exists?(path)
            FileUtils.mkdir_p(path)
            path = File.join(path, "#{vt.id}#{Constants::STACK_AGE_GRAPH_POST_FIX}")
        else
            path = File.join(path, "#{vt.id}#{Constants::STACK_AGE_GRAPH_POST_FIX}")
        end
        g.write(path)
    end

    def make_sex_graph(vt, v)
        g = Gruff::Pie.new(Constants::LARGE_GRAPH_DIM_16_9)
        g.data Constants::GRAPH_MALE_LABEL, v.male_votes.to_f / v.votes_count.to_f
        g.data Constants::GRAPH_FEMALE_LABEL, v.female_votes.to_f / v.votes_count.to_f
        path = File.join(Constants::GRAPHS_PATH, "#{vt.id}")
        if !File.exists?(path)
            FileUtils.mkdir_p(path)
            path = File.join(path, "#{v.id}#{Constants::SEX_GRAPH_POST_FIX}")
        else
            path = File.join(path, "#{v.id}#{Constants::SEX_GRAPH_POST_FIX}")
        end
        g.title = v.option
        g.write(path)
    end

    def make_pie_graph(v, vi)
        g = Gruff::Pie.new(Constants::LARGE_GRAPH_DIM_16_9)
        total_votes = v.total_votes
        vi.each do |x|
            g.data x.option, x.votes_count.to_f / total_votes.to_f
        end
        path = File.join(Constants::GRAPHS_PATH, "#{v.id}")
        if !File.exists?(path)
            FileUtils.mkdir_p(path)
            path = File.join(path, "#{v.id}#{Constants::MAIN_GRAPH_POST_FIX}")
        else
            path = File.join(path, "#{v.id}#{Constants::MAIN_GRAPH_POST_FIX}")
        end
        g.write(path)
    end

    def make_gender_graph_stacked(vt)
        g = Gruff::StackedBar.new(Constants::LARGE_GRAPH_DIM_16_9)
        g.title = "By Gender"
        vi = vt.vote_items
        male_arr = Array.new
        female_arr = Array.new
        labels_hash = Hash.new

        vi.each_with_index do |vv, i|
            male_arr << (vv.male_votes.to_f / vv.votes_for.to_f) * 100 if vv.votes_for > 0
            female_arr << (vv.female_votes.to_f / vv.votes_for.to_f) * 100 if vv.votes_for > 0
            labels_hash[i] = truncate(vv.option, :length => 10, :omission => '~')
        end
        dataset = [[:Male, male_arr], [:Female, female_arr]]
        dataset.each do |data|
            g.data(data[0], data[1])
        end
        g.labels = labels_hash
        path = File.join(Constants::GRAPHS_PATH, "#{vt.id}")
        if !File.exists?(path)
            FileUtils.mkdir_p(path)
            path = File.join(path, "#{vt.id}#{Constants::STACK_GENDER_GRAPH_POST_FIX}")
        else
            path = File.join(path, "#{vt.id}#{Constants::STACK_GENDER_GRAPH_POST_FIX}")
        end
        g.write(path)
    end

end
