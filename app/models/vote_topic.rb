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
    
    def post_process(selected_response, user)
        self.increment!(:total_votes, 1)
        #update male/female
        if !user.sex.nil? && user.sex == 0
            selected_response.increment!(:male_votes, 1)
        else
            selected_response.increment!(:female_votes, 1)
        end
        make_sex_graph(self, selected_response)
        make_pie_graph(self, self.vote_items)
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
