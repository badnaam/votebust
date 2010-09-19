class TrackingsController < ApplicationController
    
    def create
        vt = VoteTopic.find_for_tracking(params[:vt_id])
        if (@t = current_user.trackings.create(:vote_topic_id => params[:vt_id]))
            flash[:success] = "Added #{vt.header} to your tracking listing"
            vt.delay.award_tracking(1)
        else
            flash[:error] = "An error occured. Please try again."
        end
        respond_to do |format|
            format.js
        end
    end

    def destroy
        vt = VoteTopic.find_for_tracking(params[:vt_id])
        if Tracking.find(params[:id].to_i).destroy
            vt.delay.award_tracking(-1)
            flash[:success] = "Removed #{vt.header} from your tracking list."
        else
            flash[:error] = "An error occured. Please try again."
        end
        respond_to do |format|
            format.js
        end
    end

end
