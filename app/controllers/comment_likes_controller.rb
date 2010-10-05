class CommentLikesController < ApplicationController
    before_filter :require_user, :only => [:create, :destroy]
  def create
      c = CommentLike.create(:comment_id => params[:comment_id], :user_id => current_user.id)
      if !c .valid?
          flash[:error] = "Sorry an error occured, please try again"
      end
      respond_to do |format|
          format.js
      end
  end

  def destroy
      cl = CommentLike.find(:first, :conditions => ['comment_id = ? AND user_id = ?', params[:comment_id], current_user.id])
      if !cl.nil?
          cl.destroy
      end
      respond_to do |format|
          format.js
      end
  end

end
