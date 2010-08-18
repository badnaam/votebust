class PeriodicFacetJob
    def perform
        Delayed::Worker.logger.info('RAM USAGE Job Start: ' + `pmap #{Process.pid} | tail -1`[10,40].strip)
        VoteTopic.not_exp.each do |v|
            if v.facet_update_eligible?
                VoteTopic.find_for_facet_update(v.id).update_facets
            end
        end
        Delayed::Worker.logger.info('RAM USAGE Job End: ' + `pmap #{Process.pid} | tail -1`[10,40].strip)
        #        GC.start
        #        Delayed::Worker.logger.info('RAM USAGE GC End: ' + `pmap #{Process.pid} | tail -1`[10,40].strip)
        Delayed::Job.enqueue PeriodicFacetJob.new(), 0, 2.minutes.from_now
    end
end