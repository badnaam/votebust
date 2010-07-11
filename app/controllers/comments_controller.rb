class CommentsController < ApplicationController
    before_filter :require_user, :only => [:create]
    def create
        if !params[:vote_topic_id].nil?
            vt = VoteTopic.find(params[:vote_topic_id])
            if !vt.nil?
                @comment = vt.comments.create(params[:comment])
                @comment.user_id = current_user.id
                if !@comment.save
                    flash[:error] = "Comment could not be saved"
                end
            end
        end
        respond_to do |format|
            format.js
        end
    end
end
