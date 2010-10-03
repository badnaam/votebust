class CommentsController < ApplicationController
    before_filter :require_user, :only => [:create]
    before_filter :require_registration, :only => [:create]
    skip_before_filter :require_user, :only => [:index]
    
    def index
        @comments = Comment.get_comments(params[:vid], params[:vi_id], params[:page] || 1)
        respond_to do |format|
            format.js
        end
    end
    
    def create
        if @comment = Comment.do_comment(params[:comment][:body], params[:vt_id],  params[:selected_response_for_comment], current_user.id, request)
            @comment_saved = true
        else
            @comment_saved = false
        end
        respond_to do |format|
            format.js
        end
    end
end
