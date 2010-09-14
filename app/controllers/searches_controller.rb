class SearchesController < ApplicationController
    layout "main"
    def index
        term = params[:q]
        term ||= ""
        
        if params[:city]
            @search_results  = Search.city_search term, params[:city], params[:per_page] || Constants::LISTINGS_PER_PAGE, params[:page] || 1, params[:order] || 'distance'
        elsif params[:state]
            @search_results  = Search.state_search term, params[:state], params[:per_page] || Constants::LISTINGS_PER_PAGE, params[:page] || 1, params[:order] || 'recent'
        else
            @search_results  = Search.term_search term, params[:per_page] || Constants::LISTINGS_PER_PAGE, params[:page] || 1, params[:order] || 'recent'
        end
        cookies[:voteable_q] = term
        if params[:city]
            cookies[:search_context] = params[:city]
        elsif params[:state]
            cookies[:search_context] = params[:state]
        elsif params[:terms]
            cookies[:search_context] = params[:terms]
        else
            cookies[:search_context] = ""
        end
        respond_to do |format|
            format.html
            format.js
        end
    end
end
