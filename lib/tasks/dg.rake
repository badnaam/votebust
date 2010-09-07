namespace :dg do
    desc 'generate a bunch of users. Supply count=number'
    task :gen_users => :environment do
        begin
            require 'populator'
        rescue
        end
        
        count = ENV['count'].to_i
        zip_length = JobsCommon::ZIP_CODES.length
        
        (1..count).each do |i|
            begin
                u = User.new
                u.username = "user#{i}"
                u.email = Populator.words(1)+"@gmail.com"
                u.password = APP_CONFIG['stock_pwd']
                u.password_confirmation = APP_CONFIG['stock_pwd']
                u.role_id = 2
                u.active = true
                u.age = rand(45) + 13
                u.sex = rand(0)
                u.zip = JobsCommon::ZIP_CODES[rand(zip_length)]
                u.perishable_token = Authlogic::Random.friendly_token
                u.save
            rescue => exp
                puts exp.message
                puts u.inspect
            end
            if count % 500 == 0
                GC.start
            end
        end
    end


    desc 'Make each user vote on each vote_topic'
    task :generate_votes => :environment do
        VoteTopic.all.each do |v|
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
    
    desc 'create VoteTopics. Supply per_user=number'
    task :gen_vote_topics => :environment do
        require 'populator'
        if ENV['per_user']
            per_user = ENV['per_user'].to_i
        else
            per_user = 10
        end
        cat_length = Category.count

        gen_count = 0
        User.all.each do |u|
            gen_count += 1
            if gen_count % 500 == 0
                GC.start
            end
            per_user.times {
                a = Array.new
                v = u.posted_vote_topics.create(:topic => Populator.sentences(5), :header => Populator.sentences(1), :status => 'a',
                    :category_id => rand(cat_length - 1) + 1, :expires => 2.weeks.from_now)
                (rand(4) + 1).times do |y|
                    a << {:option => Populator.words(rand(3) + 1)}
                end
                v.vote_items_attributes = a
                v.save
            }
        end
    end

    desc 'Generate Comment. Supply count=number'
    task :gen_comments => :environment do
        require 'populator'
        count = ENV[:count].to_i
        user_ids = User.all.collect {|x| x.id}
        VoteTopic.all.each do |v|
            vi = v.vote_items
            count.times {
                Comment.create(
                    :body => Populator.sentences(rand(3)),
                    :vote_topic_id => v.id,
                    :vi_option => vi[rand(vi.length)].option,
                    :user_id => user_ids[rand(user_ids.length)]
                )
            }
        end
    end

    desc 'Generate Trackings'
    task :gen_trackings => :environment do
        user_ids = User.all.collect {|x| x.id}
        vt_ids = VoteTopic.all.collect {|x| x.id}

        user_ids.each do |i|
            begin
                Tracking.create(
                    :user_id => i,
                    :vote_topic_id => vt_ids[rand(vt_ids.length)]
                )
            rescue
                puts 'Validation failed trying next one'
                continue
            end
        end
    end

    task :test => :environment do
        puts Authlogic::Random.friendly_token
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