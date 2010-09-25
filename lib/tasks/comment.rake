desc 'Checks for spam in comments'
task :check_for_spam => :environment do
    Comment.spam_check
end