class PeriodicSmallJob
    def perform
#        Rails.logger.error "Periodic job writing #{Time.now}"
#        Delayed::Worker.logger.info "xyxxx"
        Delayed::Job.enqueue PeriodicSmallJob.new(), 0, 5.seconds.from_now
    end
end