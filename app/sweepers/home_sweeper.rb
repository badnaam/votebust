# To change this template, choose Tools | Templates
# and open the template in the editor.

class HomeSweeper < ActionController::Caching::Sweeper
    observe VoteTopic
  def after_index(vote_topic)
    expire_cache(vote_topic)
  end
  def after_create(vote_topic)
      expire_page :controller => :home, :action => :index
  end

  def expire_cache(vote_topic)
     expire_page :controller => :home, :action => :index
  end
end
