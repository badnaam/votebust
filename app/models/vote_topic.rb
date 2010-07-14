require 'rubygems'
require 'gruff'
class VoteTopic < ActiveRecord::Base
    belongs_to :user
    belongs_to :category
    has_many :comments
    has_many :vote_items, :dependent => :destroy


    validates_presence_of :header, :topic
    validate :min_vote_items, :if => :its_new?
    accepts_nested_attributes_for :vote_items, :limit => 5, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:option].blank? }

    after_destroy :destroy_graphs
    has_friendly_id :header, :use_slug => true, :approximate_ascii => true, :max_length => 50
    #    acts_as_mappable :through => :merchant

    #    scope_procedure :latest, lambda {created_at_gte(p[0]).created_at_lt(p[1]) }
    scope_procedure :latest, lambda {created_at_gte(Constants::SMART_COL_LATEST_LIMIT.ago) }
        
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
        make_sex_graph_stacked(self)
        make_age_graph_stacked(self)
        make_pie_graph(self, self.vote_items)
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
    
    #    def make_line_graph
    #        g = Gruff::Line.new
    #        g.title = self.header
    #
    #        g.data("Apples", [1, 2, 3, 4, 4, 3])
    #        g.data("Oranges", [4, 8, 7, 9, 8, 9])
    #        g.data("Watermelon", [2, 3, 1, 5, 6, 8])
    #        g.data("Peaches", [9, 9, 10, 8, 7, 9])
    #
    #        g.labels = {0 => '2003', 2 => '2004', 4 => '2005'}
    #
    #        path = File.join(Rails.root, "public/images/fruity.png")
    #        g.write(path)
    #    end
    #
    #
    #    def make_bar_graph
    #        g = Gruff::Bar.new
    #        g.title = self.header
    #
    #        g.data("Yes", [1, 2, 3, 4, 4, 3])
    #        g.data("No", [4, 8, 7, 9, 8, 9])
    #
    #        g.labels = {0 => 'Good', 2 => 'Better', 4 => 'Best'}
    #
    #        path = File.join(Rails.root, "public/images/bar.png")
    #        g.write(path)
    #    end
    #
    #
    #    #        g.title = self.header
    #    #        g.theme = {
    #    #            :colors => %w(green white yellow blue black),
    #    #            :marker_color => 'pink',
    #    #            :background_colors => %w(white orange)
    #    #        }
    #
    #    def make_sex_pie
    #        g = Gruff::Pie.new
    #        vi = self.vote_items
    #        vi.each do |v|
    #            voters = v.voters_who_voted
    #            male = 0
    #            female = 0
    #            voters.each do |vo|
    #                if !vo.sex.nil? && vo.sex == 0
    #                    male += 1
    #                else
    #                    female += 1
    #                end
    #            end
    #            v.update_attribute(:male_votes, male)
    #            v.update_attribute(:female_votes, female)
    #        end
    #    end
    #
    #    def make_pie_graph
    #        g = Gruff::Pie.new
    #        vi = self.vote_items
    #        total_votes = self.total_votes
    #        vi.each do |x|
    #            g.data x.option, x.votes_count.to_f / total_votes.to_f
    #        end
    #        path = File.join(Constants::GRAPHS_PATH, "#{self.id}")
    #        if !File.exists?(path)
    #            FileUtils.mkdir_p(path)
    #            path = File.join(path, "#{self.id}_pie_breakdown.png")
    #        else
    #            path = File.join(path, "#{self.id}_pie_breakdown.png")
    #        end
    #        g.write(path)
    #    end

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
end
