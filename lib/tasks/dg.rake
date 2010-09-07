namespace :dg do

    
    desc 'generate a bunch of users'
    task :gen_users => :environment do
        require 'populator'
        count = ENV['count'].to_i
        zip_length = Constants::ZIP_CODES.length
        (1..count).each {
            puts "Creating User"
            puts "#{Populator.words(rand(2) + 1)} age - #{rand(45) + 13} sex - #{User::SEX[rand(1)]} zip - #{Constants::ZIP_CODES[rand(zip_length)]}"
        }
    end

    desc 'Make each user vote on each vote_topic'
    task :generate_votes => :environment do
        if ENV['id']
            coll = VoteTopic.find(ENV['id'].to_i).to_a
        else
            coll = VoteTopic.all
        end
        coll.each do |v|
            vi = v.vote_items
            User.all.each do |u|
                Vote.do_vote(v.id, vi[rand(vi.length)], u.id, true)
            end
        end
    end
    
    desc 'Resets all vote counter'
    task :reset_votes => :environment do
        VoteTopic.all.each do |v|
            v.reset
        end
        User.all.each do |u|
            u.update_attribute(:votes_count, 0)
        end
    end
    
    desc 'create VoteTopics'
    task :gen_vote_topics => :environment do
        id = ENV['id']
        per_user = 7
        cat_length = Category.count
        if id
            arr = User.find(id).to_a
        else
            arr = User.all
        end
        arr.each do |u|
            (rand(7) + 1).times {
                a = Array.new
                v = u.posted_vote_topics.create(:topic => Populator.sentences(5), :header => Populator.sentences(1), :status => 'a',
                    :category_id => rand(cat_length) + 1, :expires => 2.weeks.from_now)
                (rand(5) + 1).times do |y|
                    a << {:option => Populator.words(rand(3) + 1)}
                end
                v.vote_items_attributes = a
                v.save
            }
        end
    end

    desc 'Generate Votes'
    task :gen_votes => :environment do
        VoteTopic.all.each do |v|
            vis = v.vote_items.collect {|x| x.id}
            User.all.each do |u|
                v.votes.create(:user_id => u.id, vote_item_id => vis[rand(vis.length)])
            end
        end
    end
    
    desc 'create categories'
    task :gen_categories => :environment do
        JobsCommon::CATEGORIES.each do |x|
            Category.create(:name => x)
        end
    end
end