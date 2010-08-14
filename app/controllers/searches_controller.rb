class SearchesController < ApplicationController
    layout "main"
    def index
        terms = params[:search_term]
        terms ||= ""
        if params[:city]
            @search_results  = VoteTopic.search terms, :conditions => {:city => params[:city]}, :page => params[:page] || 1, :per_page => Constants::LISTINGS_PER_PAGE
        elsif params[:state]
            @search_results  = VoteTopic.search terms, :conditions => {:state => params[:state]}, :page => params[:page] || 1, :per_page => Constants::LISTINGS_PER_PAGE
        else
            @search_results  = VoteTopic.search terms, :page => params[:page] || 1, :per_page => 3
        end
        respond_to do |format|
            format.html
            format.js
        end
    end
end
