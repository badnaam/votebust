class VotesController < ApplicationController
    before_filter :require_user, :only => [:create, :destroy]
    
    def index
        listing_type = params[:listing_type]
        if listing_type == "voted"
            @vts = Vote.get_voted_vote_topics(params[:user_id], false, params[:page])
        end
        respond_to do |format|
            format.js
        end
    end

    def create
        ret_val = Vote.do_vote(params[:id], params[:response], params[:user_id], true)
        if ret_val == true
            flash[:success] = "Your vote has been accepted and will be processed shortly"
        elsif ret_val == -1
            flash[:notice] = "You have already voted"
        elsif ret_val == false
            flash[:error] = "Something went wrong with processing your vote. Please try again/"
        end
        respond_to do |format|
            format.js
        end
    end

    def destroy
        ret_val = Vote.do_vote(params[:id], params[:response], params[:user_id], false)
        if ret_val == true
            flash[:success] = "Your vote has been cancelled and will be processed shortly"
        elsif ret_val == false
            flash[:notice] = "Your vote could not be cancelled. Please try again later."
        end
        respond_to do |format|
            format.js
        end
    end
    
end
