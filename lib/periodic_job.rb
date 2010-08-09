class PeriodicJob
    def perform
        Rails.logger.info "Periodic job writing #{Time.now}"
#        Rails.logger.info "Periodic job writing #{Time.now}"
#        if JobsCommon::check_job_exists("PeriodicJob").blank?
            Delayed::Job.enqueue PeriodicJob.new(), 0, 30.seconds.from_now
#        end
    end
end