class InterestsController < ApplicationController
    before_filter :require_user

    def index
        
    end
    
    def manage
        params[:interest_ids] ||= []
        unless params[:interest_ids].nil?
            current_user.interests.each do |i|
                i.destroy unless params[:interest_ids].include?(i.category_id.to_s)
                params[:interest_ids].delete(i.category_id.to_s)
            end
            params[:interest_ids].each do |i|
                current_user.interests.create(:category_id => i) unless i.blank?
            end
            flash[:notice] = "Your interests have been saved. Watch out for our updates in your inbox!"
            #reload
            #            current_user.category_ids = nil
        end
        
        respond_to do |format|
            format.js
        end
    end

end
