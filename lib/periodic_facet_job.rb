class PeriodicFacetJob
    def perform
        VoteTopic.not_exp.map{|x| x.id}.each do |i|
            VoteTopic.find_for_facet_update(i).update_facets
        end
        Delayed::Job.enqueue PeriodicFacetJob.new(), 0, 10.minutes.from_now
    end
end