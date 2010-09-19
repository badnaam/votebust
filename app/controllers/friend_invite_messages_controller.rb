class FriendInviteMessagesController < ApplicationController
  def create
      @fim = FriendInviteMessage.create(params[:friend_invite_message])
      @fim.user_id = current_user.id
      if @fim.save
          flash[:success] = "Sent invitation to friends! Feel free to invite more."
           @fim.delay.deliver_friend_invite_message!
      else
          flash[:error] = "Failed to send invitation to friends. Please try again."
      end
      respond_to do |format|
          format.html {redirect_to user_path(current_user)}
      end
  end
end
