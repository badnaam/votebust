class CommentsController < ApplicationController
    before_filter :require_user, :only => [:create]
    def index
        @comments = Comment.vote_topic_id_equals(params[:vid]).vi_id_equals(params[:vi_id]).paginate(:order => 'created_at DESC', :page => params[:page] || 1, :per_page => 2)
        if params[:paginated]
            @paginated = true
        end
        respond_to do |format|
            format.js
        end
    end
    
    def create
        if Comment.do_comment(params[:comment][:body], params[:vt_id],  params[:selected_response_for_comment], current_user.id) == true
            @comment_saved = true
        else
            @comment_saved = false
        end
        respond_to do |format|
            format.js
        end
    end
end
