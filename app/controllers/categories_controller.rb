class CategoriesController < ApplicationController
    
    def index
        @listing_type = params[:type]
        @categories = Category.all(:select => 'id, name')
        respond_to do |format|
            format.js
        end
    end
end
