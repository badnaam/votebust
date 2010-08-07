class CommentsController < ApplicationController
    before_filter :require_user, :only => [:create]
    def index
        @comments = Comment.vote_topic_id_equals(params[:vid]).vi_option_equals(params[:option]).paginate(:page => params[:page] || 1, :per_page => 2)
        @active_option = params[:option].gsub(/\s/,'')
        if params[:paginated]
            @paginated = true
        end
        respond_to do |format|
            format.js
        end
    end
    
    def create
        if !params[:vote_topic_id].nil?
            vt = VoteTopic.find(params[:vote_topic_id], :include => :vote_items)
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
