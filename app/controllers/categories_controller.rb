class CategoriesController < ApplicationController
    def index
        @categories = Category.all(:select => 'id, name')
        respond_to do |format|
            format.js
        end
    end
end
