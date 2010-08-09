Delayed::Worker.backend = :active_record
#Delayed::Worker.logger = Rails.logger
Delayed::Worker.logger = ActiveSupport::BufferedLogger.new("log/
##{Rails.env}_delayed_jobs.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1
class Delayed::Job
    def logger
        Delayed::Worker.logger
    end
end
#if JobsCommon::check_job_exists("PeriodicJob").blank?
#    Delayed::Job.enqueue PeriodicJob.new(), 0, 30.seconds.from_now
#end
#end