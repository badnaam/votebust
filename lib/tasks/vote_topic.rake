desc "calculates the unan column of all active vote_topics, sets it to true if the topic is unananimous"
task :compute_devided_counter => :environment do
    VoteTopic.status_equals('a').all.each do |v|
        if v.determine_devided == false
            puts '#{v.topic} is unanimous'
        else
            puts '#{v.topic} is devided'
        end
    end
end