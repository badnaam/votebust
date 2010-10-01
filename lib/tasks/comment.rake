desc 'Checks for spam in comments'
task :check_for_spam => :environment do
    begin
        Comment.spam_check
    rescue Exception => e
        Rails.logger.error "Checking for spam failed!"
    end
end

