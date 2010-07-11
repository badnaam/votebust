class SearchesController < ApplicationController
    layout "main"
    def index
        terms = params[:search_term]
        terms ||= ""
        @search_results  = ThinkingSphinx.search terms, :page => params[:page] || 1, :per_page => 3
        respond_to do |format|
            format.html
            format.js
        end
    end
end
