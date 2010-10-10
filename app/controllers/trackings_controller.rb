class TrackingsController < ApplicationController
    before_filter :require_user, :only => [:create, :destroy]
    before_filter :require_registration, :only => [:create, :destroy]
    
    def create
        if (@t = current_user.trackings.create(:vote_topic_id => params[:vt_id]))
        else
            flash[:error] = "An error occured. Please try again."
        end
        respond_to do |format|
            format.js
        end
    end

    def destroy
        if Tracking.find(params[:id].to_i).destroy
        else
            flash[:error] = "An error occured. Please try again."
        end
        respond_to do |format|
            format.js
        end
    end

end
