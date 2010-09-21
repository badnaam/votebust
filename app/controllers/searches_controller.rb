class SearchesController < ApplicationController
    layout "main"
    def index
        term = params[:q]
        term ||= ""
        
        if params[:city]
            @search_results  = Search.city_search params[:city], params[:per_page] || Constants::LISTINGS_PER_PAGE, params[:page] || 1, params[:order] || 'distance'
            cookies[:current_search_city] = params[:city]
        elsif params[:state]
            @search_results  = Search.state_search  params[:state], params[:per_page] || Constants::LISTINGS_PER_PAGE, params[:page] || 1, params[:order] || 'recent'
            cookies[:current_search_state] = params[:state]
        else
            @search_results  = Search.term_search term, params[:per_page] || Constants::LISTINGS_PER_PAGE, params[:page] || 1, params[:order] || 'recent'
        end
#        @search_results = @search_results.to_a
        cookies[:voteable_q] = term
        #todo : what is cookies are disabled?
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
