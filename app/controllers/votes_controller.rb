class VotesController < ApplicationController
    def index
        @listing_type = params[:listing_type]
        @paginated = params[:paginated]
        if @listing_type == "voted"
            @vts = Vote.get_voted_vote_topics(params[:user_id], false, params[:page])
        end
        respond_to do |format|
            format.js
        end
    end
end
