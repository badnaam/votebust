class SearchesController < ApplicationController
    layout "main"
    def index
        terms = params[:search_term]
        terms ||= ""
        if params[:city]
            @search_results  = VoteTopic.search terms, :conditions => {:city => params[:city]}, :page => params[:page] || 1, :per_page => Constants::LISTINGS_PER_PAGE,
              :include => [{:vote_items => :votes}, :poster, :category], :select => Constants::VOTE_TOPIC_FIELDS
            @search_context = params[:city]
        elsif params[:state]
            @search_results  = VoteTopic.search terms, :conditions => {:state => params[:state]}, :page => params[:page] || 1, :per_page => Constants::LISTINGS_PER_PAGE,
              :include => [{:vote_items => :votes}, :poster, :category], :select => Constants::VOTE_TOPIC_FIELDS
            @search_context = params[:state]
        else
            @search_results  = VoteTopic.search terms, :page => params[:page] || 1, :per_page => Constants::LISTINGS_PER_PAGE,
              :include => [{:vote_items => :votes}, :poster, :category], :select => Constants::VOTE_TOPIC_FIELDS
            @search_context = terms
        end
        cookies[:search_context] = @search_context
        respond_to do |format|
            format.html
            format.js
        end
    end
end
