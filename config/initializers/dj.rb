Delayed::Worker.backend = :active_record

#Delayed::Worker.logger = Rails.logger
Delayed::Worker.logger = ActiveSupport::BufferedLogger.new("log/
##{Rails.env}_delayed_jobs.log#", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1
class Delayed::Job
    def logger
        Delayed::Worker.logger
    end
end
if JobsCommon::check_job_exists("PeriodicFacetJob").blank?
    Delayed::Job.enqueue PeriodicFacetJob.new(), 0, 60.seconds.from_now
end
#if JobsCommon::check_job_exists("PeriodicSmallJob").blank?
#    Delayed::Job.enqueue PeriodicSmallJob.new(), 0, 10.seconds.from_now
#end
#end