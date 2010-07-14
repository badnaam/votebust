require 'rubygems'
require 'gruff'
include ActionView::Helpers::TextHelper

class VoteProcessJob

    def perform
        vi = VoteItem.all
        vi.each do |v|
            voters = v.voters_who_voted
            male = 0
            female = 0
            voters.each do |vo|
                if !vo.sex.nil? && vo.sex == 0
                    male += 1
                else
                    female += 1
                end
            end
            v.update_attribute(:male_votes, male)
            v.update_attribute(:female_votes, female)
            total = v.votes_count
            v.vote_topic.increment!(:total_votes, total)
        end
        vote_topics = VoteTopic.all
        vote_topics.each do |vt|
            make_pie_graph(vt, vt.vote_items)
            make_sex_graph(vt.vote_items)
        end
    end

    def reset_age_breakdown
        VoteItem.all.each do |v|
            v.update_attribute(:ag_1_v, 0)
            v.update_attribute(:ag_2_v, 0)
            v.update_attribute(:ag_3_v, 0)
            v.update_attribute(:ag_4_v, 0)
        end
    end

    def calculate_age_breakdown
        Vote.all.each do |v|
            u = v.voter
            vi = v.voteable
            age = u.age
            if Constants::AGE_GROUP_1.include?(age)
                vi.increment!(:ag_1_v, 1)
            elsif Constants::AGE_GROUP_2.include?(age)
                vi.increment!(:ag_2_v, 1)
            elsif Constants::AGE_GROUP_3.include?(age)
                vi.increment!(:ag_3_v, 1)
            else
                vi.increment!(:ag_4_v, 1)
            end
        end
    end
    
    def refresh_graphs
        vote_topics = VoteTopic.all
        vote_topics.each do |vt|
            make_pie_graph(vt, vt.vote_items)
            make_gender_graph_stacked(vt)
            make_age_graph_stacked(vt)
        end
    end
    
    def pie_test
        g = Gruff::Pie.new(400)
        g.data "a", 50
        g.data "b", 50
        path = File.join(Constants::GRAPHS_PATH, "test/test.png")
        g.write(path)
    end
    def mini_pie_test
        g = Gruff::Mini::Pie.new
        g.hide_legend = true
        g.margins=2
        g.data "a", 50
        g.data "b", 50
        
        
        path = File.join(Constants::GRAPHS_PATH, "test/mini_pie_test.png")
        g.write(path)
    end

    def stack_test
        g = Gruff::StackedBar.new
        g.title = "My Graph"

        @datasets = [
            [:Male, [10, 36, 86, 39]],
            [:Female, [90, 64, 14, 61]],
        ]
        @datasets.each do |data|
            g.data(data[0], data[1])
        end
        g.maximum_value
        g.y_axis_label
        g.theme_pastel
        g.labels = {0 => 'Big Issue 0', 1 => 'Big Issue 1 Big IssueBig IssueBig IssueBig Issue', 2 => 'Big Issue Big IssueBig Issue2', 3 => ' Big Issue Big Issue3'}
        path = File.join(Constants::GRAPHS_PATH, "test/stack_test.png")
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

    def make_sex_graph(vi)
        vi.each do |v|
            g = Gruff::Pie.new(Constants::LARGE_GRAPH_DIM_16_9)
            g.data Constants::GRAPH_MALE_LABEL, v.male_votes.to_f / v.votes_count.to_f
            g.data Constants::GRAPH_FEMALE_LABEL, v.female_votes.to_f / v.votes_count.to_f
            path = File.join(Constants::GRAPHS_PATH, "#{v.vote_topic.id}")
            if !File.exists?(path)
                FileUtils.mkdir_p(path)
                path = File.join(path, "#{v.id}#{Constants::SEX_GRAPH_POST_FIX}")
            else
                path = File.join(path, "#{v.id}#{Constants::SEX_GRAPH_POST_FIX}")
            end
            g.title = v.option
            g.write(path)
        end
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
end