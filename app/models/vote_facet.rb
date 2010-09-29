class VoteFacet < ActiveRecord::Base
    belongs_to :vote_topic

    #expire this cache after the facet update
    def self.find_for_show id
        Rails.cache.fetch("vt_facet_#{id}") do
            find(:first, :conditions => ['vote_topic_id = ?', id])
        end
    end
end
