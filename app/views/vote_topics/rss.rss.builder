xml.channel do
    # Required to pass W3C validation.
    xml.atom :link, nil, {
        :href => rss_vote_topics_url(:format => 'rss'),
        :rel => 'self', :type => 'application/rss+xml'
    }

    # Feed basics.
    xml.title            "Voteable Feeds"
    xml.description       "Voteable - Get the collective opinion."
    xml.link              rss_vote_topics_url(:format => 'rss')

    # Posts.
    @vote_topics.each do |v|
        xml.item do
            xml.title         v.header
            xml.link          vote_topic_url(v)
            xml.pubDate       v.created_at.to_s(:rfc822)
            xml.guid          vote_topic_url(v)
        end
    end
end