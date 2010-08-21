class SearchesController < ApplicationController
    layout "main"
    def index
        terms = params[:search_term]
        terms ||= ""
        if params[:city]
            @search_results  = VoteTopic.search terms, :conditions => {:city => params[:city]}, :page => params[:page] || 1, :per_page => Constants::LISTINGS_PER_PAGE,
              :include => [{:vote_items => :votes}, :poster, :category], :select => Constants::VOTE_TOPIC_FIELDS
        elsif params[:state]
            @search_results  = VoteTopic.search terms, :conditions => {:state => params[:state]}, :page => params[:page] || 1, :per_page => Constants::LISTINGS_PER_PAGE,
              :include => [{:vote_items => :votes}, :poster, :category], :select => Constants::VOTE_TOPIC_FIELDS
        else
            @search_results  = VoteTopic.search terms, :page => params[:page] || 1, :per_page => 3,
              :include => [{:vote_items => :votes}, :poster, :category], :select => Constants::VOTE_TOPIC_FIELDS
        end
        #        if @search_results.total_entries > 0
        #            Search.create(:term => terms)
        #        end
        respond_to do |format|
            format.html
            format.js
        end
    end
end
