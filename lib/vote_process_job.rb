require 'rubygems'
require 'gruff'

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

    def refresh_graphs
        vote_topics = VoteTopic.all
        vote_topics.each do |vt|
            make_pie_graph(vt, vt.vote_items)
            make_sex_graph(vt.vote_items)
        end
    end
    
    def pie_test
        g = Gruff::Pie.new(400)
        g.data "a", 50
        g.data "b", 50
        path = File.join(Constants::GRAPHS_PATH, "test/test.png")
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