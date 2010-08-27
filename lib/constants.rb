class Constants

    RPX_PROVIDERS = ["Facebook", "Twitter", "Google"]
    SHARE_URL_PREFIX = "http://web1.tunnlr.com:11299"
    SITE_COLOR = '#38385c'
    USER_PROFILE_IMAGE_SIZE = "50x50"
    MISSING_IMAGE_FILE = 'small/missing.png'
    GRAPHS_PATH = File.join(Rails.root, "public/assets/images/graphs")
    VOTE_PROCESS_FREQ = 30.minutes
    VOTE_REFRESH_INTERVAL = 2000000
    MAX_COMMENT_LENGTH = 500
    LISTINGS_PER_PAGE = 3
    PROXIMITY = 50
    WIDE_PROXIMITY = 1000
    
    GRAPH_TITLE_STYLE = '{font-size: 12px; color: #F24062;font-weight: bold;font-family:Verdana; text-align: center;}' 
    GRAPH_X_AXIS_LABEL_COLOR = '#000000'
    GRAPH_X_AXIS_LABEL_FONT_SIZE = 12
    GRAPH_X_AXIS_LABEL_ANGLE = 0
    GRAPH_X_AXIS_LABEL_LENGTH = 10
    GRAPH_KEY_SIZE = 10
    GRAPH_AXIS_COLOR = '#ffffff'
    GRAPH_GRID_COLOR = '#ffffff'
    GRAPHS_BG_COLOR = '#ffffff'
    GRAPH_MALE_COLOR = '#C4D318'
    GRAPH_FEMALE_COLOR = '#50284A'
    GRAPH_MALE_LABEL = "Men"
    GRAPH_FEMALE_LABEL = "Women"
    GENDER_GRAPH_TITLE = "Men vs Women"
    AGE_GRAPH_TITLE = "Age Group"
    GRAPH_AG1_COLOR = '#C4D318'
    GRAPH_AG2_COLOR = '#50284A'
    GRAPH_AG3_COLOR = '#2AB597'
    GRAPH_AG4_COLOR = '#B00E21'

    LARGE_GRAPH_WIDTH = 650
    LARGE_GRAPH_HEIGHT = 450
    LARGE_GRAPH_HEIGHT_16_9 = 400
    LARGE_GRAPH_DIM_16_9 = '600x338'

   
    MAX_VOTE_HEADER_LENGTH  = 500
    MAX_VOTE_TOPIC_LENGTH  =  999
    MAX_VOTE_TOPIC_FEMAILS  = 500
    MAX_VOTE_EXT_LINK_LENGTH  = 150

    COMMENTS_PER_PAGE = 3

    RPX_APP_NAME = "votebust"

    SMART_COL_LIMIT = 5
    SMART_COL_LATEST_LIMIT = 24.days

    USER_AGE_RANGE = (10..99)
    AGE_GROUP_1 = (10..19)
    AGE_GROUP_2 = (20..35)
    AGE_GROUP_3 = (35..55)
    AGE_GROUP_4 = (55..99)

    ADMIN_EMAIL = 'pjointadm@gmail.com'

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
    #########End Points########

    FACET_UPDATE_ELIGIBILITY_DELTA = 0.15
    VOTE_TOPIC_FIELDS = 'vote_topics.id, vote_topics.header, vote_topics.topic, vote_topics.user_id, vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes,
                        categories.id, categories.name, users.id, users.username, vote_items.option, vote_items.v_count, vote_topics.trackings_count, users.city,
                        users.state, users.zip, vote_topics.power_offered, vote_topics.website, users.image_url, users.image_file_name, users.image_content_type,
                        users.voting_power'
    VOTE_TOPIC_FIELDS_SHOW = 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topics.expires, vote_topics.topic, vote_topics.user_id, vote_topics.category_id,
                             vote_topics.created_at,vote_topics.total_votes, categories.id, categories.name,  users.id, users.username,vote_items.option, total_votes,
                             comments.id, comments.body, comments.user_id, comments.vote_topic_id, vote_facets.m, vote_facets.w, vote_facets.ag1, vote_facets.ag2, vote_facets.ag3,
                             vote_facets.ag4, vote_facets.dag, vote_facets.wl, vote_facets.ll, vote_facets.vl,, vote_topics.trackings_count, vote_topics.power_offered,
                             vote_topics.website, users.image_url, users.image_file_name, users.image_content_type, users.voting_power, users.city, users.state'
end
