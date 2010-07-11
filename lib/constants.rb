class Constants
    GRAPHS_PATH = File.join(Rails.root, "public/assets/images/graphs")
    VOTE_PROCESS_FREQ = 8.hours
    GRAPH_MALE_LABEL = "Men"
    GRAPH_FEMALE_LABEL = "Women"
    SMALL_GRAPH_WIDTH = 400
    LARGE_GRAPH_WIDTH = 600
    LARGE_GRAPH_HEIGHT = 450
    LARGE_GRAPH_DIM_16_9 = '600x338'
    SEX_GRAPH_POST_FIX = "_sex_breakdown.png"
    MAIN_GRAPH_POST_FIX = "_pie_breakdown.png"
    GRAPH_ASSET_DIR = '/assets/images/graphs'

    COMMENTS_PER_PAGE = 3
end