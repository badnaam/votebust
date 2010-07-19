class Constants
    SITE_COLOR = '#38385c'
        
    GRAPHS_PATH = File.join(Rails.root, "public/assets/images/graphs")
    VOTE_PROCESS_FREQ = 8.hours

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