require 'test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
    
    def test_homepage
        1000.times do
            get '/'
        end
    end
    
    def test_vote_show_page
        500.times do
            get '/vote_topics/entertainment/what-is-the-best-reality-show-you-ever-watched'
        end
    end
end
