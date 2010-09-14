class ModelHelpers
    def self.determine_order order
        case order
        when 'recent'
            'vote_topics.created_at DESC'
        when 'votes'
            'vote_topics.votes_count DESC'
        when 'featured'
            'vote_topics.power_offered DESC'
        when 'distance'
            '@geodist ASC'
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
        else
            'created_at DESC'
        end
    end

end