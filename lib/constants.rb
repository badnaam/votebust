class Constants

    METERS_PER_MILE = 1609.344

    SORT_ORDERS = ["recent", "votes", "featured"]
    SEARCH_SORT_ORDERS = ["recent", "votes", "featured", "distance"]
    
    RSS_TIME_HORIZON = 4.weeks
    RPX_PROVIDERS = ["Facebook", "Twitter", "Google"]
#    SHARE_URL_PREFIX = "http://web1.tunnlr.com:11299"

    SITE_COLOR = '#38385c'
    USER_PROFILE_IMAGE_SIZE = "25x25"
    USER_PROFILE_IMAGE_SIZE_LARGE = "50x50"
    MISSING_IMAGE_FILE = '/images/missing.png'
    VOTE_PROCESS_FREQ = 30.minutes
    MOST_FLAG_TIME_HORIZON = 4.weeks
    VOTE_REFRESH_INTERVAL = 50000000
    MAX_COMMENT_LENGTH = 500
    COMMENTS_AT_A_TIME = 10
    COMMENT_SPAM_CHECK_FREQUENCY = 1.hour
    
    LISTINGS_PER_PAGE = 10
    SIDEBAR_LISTING_NUM = 7
    PROXIMITY = 50
    FACET_PROCESSING_BATCH_SIZE = 20
    WIDE_PROXIMITY = 1000
    LIMITED_LISTING_CACHE_EXPIRATION = 30.minutes
    
    
    MAX_VOTE_HEADER_LENGTH  = 200
    MAX_VOTE_TOPIC_LENGTH  =  1000
    MAX_VOTE_TOPIC_FEMAILS  = 500
    MAX_VOTE_ITEM_OPTION = 150
    COMMENTS_PER_PAGE = 3

    RPX_APP_NAME = "votebust"

    SMART_COL_LIMIT = 5
    HOME_PAGE_SMART_COL_LIMIT = 15
    SMART_COL_LATEST_LIMIT = 7.days
    SMART_COL_USER_LIMIT = 14 #increment of 7

    USER_AGE_RANGE = (10..99)
    AGE_GROUP_1 = (10..19)
    AGE_GROUP_2 = (20..35)
    AGE_GROUP_3 = (35..55)
    AGE_GROUP_4 = (55..99)
    UNAN_LIMIT = 51

    SIDE_BAR_LINK_LENGTH = 50
    ######## vote listings ################
    AJAX_VOTE_TOPICS_LISTING_TYPE = ["local", "most_tracked", "top", "featured", "user_tracked_all", "recent", "user_all", "voted"]
    ########Points#############
    REGISTRATION_COMPLETE_POINTS = 10
    NEW_VOTE_POINTS = 10
    VOTE_POINTS = 1
    TRACK_POINTS = 1
    MIN_VOTE_FOR_FEATURED = 50
    VOTING_POWER_OFFER_INCREMENT = 10
    VOTING_POWER_OFFER_DEVIDER = 10
    VOTING_POWER_NORMAL_USER = 100
    VOTING_POWER_AVERAGE_USER = 200
    VOTING_POWER_HIGH_USER = 400
    VOTING_POWER_SUPER_USER = 600

    #########End Points########

    VOTING_COUNTER_RESET_INTERVAL = 30000
    ########## Vote comment processing###########
    VOTE_COMMENT_PROCESSING_INTERVAL = 6.months
    VOTE_BATCH_SIZE = 100
    ############ End Vote comment processing
    MAX_VOTES_PER_INTERVAL = 3
    
    FACET_UPDATE_ELIGIBILITY_DELTA = 0.15

    MOST_VOTED_LIST_SIZE = 50
    #remove vote_items.v_count
    VOTE_TOPIC_FIELDS = 'vote_topics.anon, vote_topics.id, vote_topics.header, vote_topics.topic, vote_topics.user_id, vote_topics.expires, vote_topics.category_id,
                        vote_topics.created_at,categories.id, categories.name, users.id, users.username, vote_items.option, vote_topics.trackings_count, users.city,
                        users.state, users.zip, vote_topics.power_offered, vote_topics.website, users.image_url, users.image_file_name, users.image_content_type,
                        users.voting_power, vote_items.votes_count, vote_topics.votes_count, vote_topics.flags, vote_topics.cached_slug, categories.cached_slug,
                        users.user_cached_slug'


    VOTE_TOPIC_FIELDS_SHOW = 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topics.expires, vote_topics.topic, vote_topics.user_id, vote_topics.category_id,
                             vote_topics.created_at, categories.id, categories.name,  users.id, users.username,vote_items.option, 
                              vote_facets.m, vote_facets.w, vote_facets.ag1, vote_facets.ag2, vote_facets.ag3,
                             vote_facets.ag4, vote_facets.dag, vote_facets.wl, vote_facets.ll, vote_facets.vl, vote_topics.trackings_count, vote_topics.power_offered,
                             vote_topics.website, users.image_url, users.image_file_name, users.image_content_type, users.voting_power, users.city, users.state,
                               vote_items.votes_count, vote_topics.votes_count, vote_topics.flags'

    VOTE_TOPIC_FIELDS_PREV_SAVE = 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topics.expires, vote_topics.topic, vote_topics.user_id, vote_topics.category_id,
                             vote_topics.created_at, categories.id, categories.name,  users.id, users.username,vote_items.option,
                              vote_topics.trackings_count, vote_topics.power_offered,slugs.scope, slugs.sluggable_id, slugs.sequence, slugs.id, slugs.name, slugs.sluggable_type,
                             vote_topics.website, users.image_url, users.image_file_name, users.image_content_type, users.voting_power, users.city, users.state,
                               vote_items.votes_count, vote_topics.votes_count, vote_topics.flags, vote_topics.cached_slug, categories.cached_slug, users.user_cached_slug'
    
    VOTE_TOPIC_FIELDS_APPROVAL = 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topics.expires, vote_topics.user_id,
                             vote_topics.created_at, vote_topics.power_offered, users.id, users.username, users.email, users.voting_power, vote_topics.friend_emails,
                            , vote_topics.cached_slug, categories.cached_slug, users.user_cached_slug, slugs.scope, slugs.sluggable_id, slugs.sequence, slugs.id, slugs.name,
                        slugs.sluggable_type'


end
