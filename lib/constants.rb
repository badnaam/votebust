class Constants
    GRAPHS_PATH = File.join(Rails.root, "public/assets/images/graphs")
    VOTE_PROCESS_FREQ = 8.hours
    GRAPH_MALE_LABEL = "Men"
    GRAPH_FEMALE_LABEL = "Women"
    SMALL_GRAPH_WIDTH = 400
    LARGE_GRAPH_WIDTH = 650
    LARGE_GRAPH_HEIGHT = 450
    LARGE_GRAPH_HEIGHT_16_9 = 400
    GRAPH_X_LABEL_LENGTH = 10
    LARGE_GRAPH_DIM_16_9 = '600x338'

    SEX_GRAPH_POST_FIX = "_sex_breakdown.png"
    STACK_AGE_GRAPH_POST_FIX = "_stack_age_breakdown.png"
    STACK_GENDER_GRAPH_POST_FIX = "_stack_gender_breakdown.png"
    MAIN_GRAPH_POST_FIX = "_pie_breakdown.png"
    GRAPH_ASSET_DIR = '/assets/images/graphs'
   
    MAX_VOTE_TOPIC_HEADER  = 1000
    MAX_VOTE_TOPIC_FEMAILS  = 500

    COMMENTS_PER_PAGE = 3

    RPX_APP_NAME = "votebust"

    SMART_COL_LIMIT = 5
    SMART_COL_LATEST_LIMIT = 7.days

    USER_AGE_RANGE = (10..99)
    AGE_GROUP_1 = (10..19)
    AGE_GROUP_2 = (20..35)
    AGE_GROUP_3 = (35..55)
    AGE_GROUP_4 = (55..99)

    ADMIN_EMAIL = 'pjointadm@gmail.com'
end