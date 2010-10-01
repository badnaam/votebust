desc 'Checks for spam in comments'
task :check_for_spam => :environment do
    begin
        Comment.spam_check
    rescue Exception => e
    end
end

task :test_hp => :environment do
#    begin
        Comment.bad_meth
#    rescue Exception => e
        
#    end
end