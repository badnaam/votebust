class HomeController < ApplicationController
    #caches_page :index
    #before_filter :store_location


    def index
        if cookies[:show_voteable_intro].nil?
            cookies[:show_voteable_intro] = 1
        end
    end

end
