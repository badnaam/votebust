Delayed::Worker.backend = :active_record
#Delayed::Worker.logger = Rails.logger
Delayed::Worker.logger = ActiveSupport::BufferedLogger.new("log/
#{Rails.env}_delayed_jobs.log", Rails.logger.level)
class Delayed::Job
    def logger
        Delayed::Worker.logger
    end
end
#if JobsCommon::check_job_exists("VoteProcessJob").blank?
#    Delayed::Job.enqueue VoteProcessJob.new(), 0, Constants::VOTE_PROCESS_FREQ.from_now
#end