class FriendInviteMessagesController < ApplicationController
    before_filter :require_registration, :only => [:create]
    def create
        @fim = FriendInviteMessage.create(params[:friend_invite_message])
        @fim.user_id = current_user.id
        if @fim.save
            flash[:success] = "Message sent! Feel free to invite more."
            @fim.delay.deliver_friend_invite_message! params[:email_type]
        else
            flash[:error] = "Failed to send message. Please make sure email addresses are corrrect."
        end
        respond_to do |format|
            format.html {redirect_back_or_default(root_path)}
        end
    end
end
