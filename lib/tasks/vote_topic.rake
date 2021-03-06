desc "calculates the unan column of all active vote_topics, sets it to true if the topic is unananimous"
task :compute_devided_counter => :environment do
    VoteTopic.status_equals(VoteTopic::STATUS[:approved]).all.each do |v|
        if v.determine_devided == false
            puts '#{v.topic} is unanimous'
        else
            puts '#{v.topic} is devided'
        end
    end
end

desc 'starts facet update'
task :facet_update_start => :environment do
    Rails.logger.info "Starting Facet Update Rake Task"
    VoteTopic.start_facet_update
end

desc 'updates flags on topics'
task :update_vote_topic_flags => :environment do
    Rails.logger.info "Start Vote Topic flag update Task"
    VoteTopic.process_vote_topic_flags
end

desc 'start vote processing'
task :process_votes => :environment do
    Rails.logger.info "Starting Process Vote Rake Task"
    Vote.process_votes
end

desc 'Send interest updates'
task :send_interest_update => :environment do
    Rails.logger.info "Starting email update to user's process"
    Interest.send_interest_updates
end

desc 'test'
task :log_test => :environment do
    Vote.test_log
end
