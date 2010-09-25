module ModelHelpers
    def self.determine_order order
        case order
        when 'recent'
            'vote_topics.created_at DESC'
        when 'votes'
            'vote_topics.votes_count DESC'
        when 'featured'
            'vote_topics.power_offered DESC'
        when 'distance'
            'distance ASC'
        when 'tracking'
             'vote_topics.trackings_count DESC'
        else
            'vote_topics.created_at DESC'
        end
    end

    def self.determine_order_search order
        case order
        when 'recent'
            'created_at DESC'
        when 'votes'
            'votes_count DESC'
        when 'featured'
            'power_offered DESC'
        when 'distance'
            '@geodist ASC'
        when 'tracking'
            'trackings_count DESC'
        else
            'created_at DESC'
        end
    end

    def self.prod?
        Rails.env == "production"
    end
    
end