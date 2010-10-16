require 'test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
    
  def test_homepage
    get '/'
  end
  def test_vote_show_page
      get '/vote_topics/entertainment/what-is-the-best-reality-show-you-ever-watched'
  end
end
