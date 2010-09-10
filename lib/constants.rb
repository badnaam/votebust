class Constants

    RSS_TIME_HORIZON = 4.weeks
    RPX_PROVIDERS = ["Facebook", "Twitter", "Google"]
    SHARE_URL_PREFIX = "http://web1.tunnlr.com:11299"

    SITE_COLOR = '#38385c'
    USER_PROFILE_IMAGE_SIZE = "50x50"
    MISSING_IMAGE_FILE = 'small/missing.png'
    VOTE_PROCESS_FREQ = 30.minutes
    MOST_FLAG_TIME_HORIZON = 4.weeks
    VOTE_REFRESH_INTERVAL = 50000000
    MAX_COMMENT_LENGTH = 500

    LISTINGS_PER_PAGE = 3
    PROXIMITY = 50
    FACET_PROCESSING_BATCH_SIZE = 20
    WIDE_PROXIMITY = 1000
    
    
    MAX_VOTE_HEADER_LENGTH  = 500
    MAX_VOTE_TOPIC_LENGTH  =  999
    MAX_VOTE_TOPIC_FEMAILS  = 500
    MAX_VOTE_EXT_LINK_LENGTH  = 150

    COMMENTS_PER_PAGE = 3

    RPX_APP_NAME = "votebust"

    SMART_COL_LIMIT = 5
    SMART_COL_LATEST_LIMIT = 7.days

    USER_AGE_RANGE = (10..99)
    AGE_GROUP_1 = (10..19)
    AGE_GROUP_2 = (20..35)
    AGE_GROUP_3 = (35..55)
    AGE_GROUP_4 = (55..99)


    SIDE_BAR_LINK_LENGTH = 50

    DEVIDED_BUFFER = 5
    DEVIDED_QUORUM = 100

    UNAN_LIMIT = 60

    OTHER_VI = "99OTHER99"

    ########Points#############
    REGISTRATION_COMPLETE_POINTS = 10
    NEW_VOTE_POINTS = 10
    VOTE_POINTS = 1
    TRACK_POINTS = 1
    MIN_VOTE_FOR_FEATURED = 50
    VOTING_POWER_OFFER_INCREMENT = 10
    VOTING_POWER_OFFER_DEVIDER = 10
    #########End Points########

    VOTING_COUNTER_RESET_INTERVAL = 30000
    MAX_VOTES_PER_INTERVAL = 3
    
    FACET_UPDATE_ELIGIBILITY_DELTA = 0.15
    MOST_VOTED_LIST_SIZE = 50
    #remove vote_items.v_count
    VOTE_TOPIC_FIELDS = 'vote_topics.id, vote_topics.header, vote_topics.topic, vote_topics.user_id, vote_topics.expires, vote_topics.category_id, vote_topics.created_at,
                        categories.id, categories.name, users.id, users.username, vote_items.option, vote_topics.trackings_count, users.city,
                        users.state, users.zip, vote_topics.power_offered, vote_topics.website, users.image_url, users.image_file_name, users.image_content_type,
                        users.voting_power, vote_items.votes_count, vote_topics.votes_count, vote_topics.flags'

    VOTE_TOPIC_FIELDS_SHOW = 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topics.expires, vote_topics.topic, vote_topics.user_id, vote_topics.category_id,
                             vote_topics.created_at, categories.id, categories.name,  users.id, users.username,vote_items.option, 
                             comments.id, comments.body, comments.user_id, comments.vote_topic_id, vote_facets.m, vote_facets.w, vote_facets.ag1, vote_facets.ag2, vote_facets.ag3,
                             vote_facets.ag4, vote_facets.dag, vote_facets.wl, vote_facets.ll, vote_facets.vl, vote_topics.trackings_count, vote_topics.power_offered,
                             vote_topics.website, users.image_url, users.image_file_name, users.image_content_type, users.voting_power, users.city, users.state,
                               vote_items.votes_count, vote_topics.votes_count, vote_topics.flags'

    VOTE_TOPIC_FIELDS_PREV_SAVE = 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topics.expires, vote_topics.topic, vote_topics.user_id, vote_topics.category_id,
                             vote_topics.created_at, categories.id, categories.name,  users.id, users.username,vote_items.option,
                              vote_topics.trackings_count, vote_topics.power_offered,
                             vote_topics.website, users.image_url, users.image_file_name, users.image_content_type, users.voting_power, users.city, users.state,
                               vote_items.votes_count, vote_topics.votes_count, vote_topics.flags'
    VOTE_TOPIC_FIELDS_APPROVAL = 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topics.expires, vote_topics.user_id,
                             vote_topics.created_at, vote_topics.power_offered, users.id, users.username, users.email, users.voting_power, vote_topics.friend_emails'


end
