class UserSessionsController < ApplicationController
    #    before_filter :require_no_user, :only => [:new, :create]
    #    before_filter :require_user, :only => :destroy
    before_filter :require_user, :except => [:index, :new, :create]
#    before_filter :header_exempt
    #    rpx_extended_info
    layout "login"

    def index
        redirect_to current_user ? root_url : new_user_sessions_url
    end
    
    def new
        @user_session = UserSession.new
    end

    def create
        @user_session = UserSession.new(params[:user_session])
        if @user_session.save
            if @user_session.new_registration?
                flash[:notice] = "Welcome! Please review your profile information before continuing"
#                redirect_to edit_user_path((current_user == nil) ? @user_session.record : current_user)
                redirect_to edit_user_path(current_user)
            else
                if @user_session.registration_complete?
                    flash[:notice] = "Welcome #{current_user.username}"
                    redirect_back_or_default root_url
                else
                    flash[:notice] = "Welcome back! Please complete required registration details before continuing.."
#                    redirect_to edit_user_path((current_user == nil) ? @user_session.record : current_user)
                    redirect_to edit_user_path(current_user)
                end
            end
        else
            logger.debug @user_session.inspect
            flash[:error] = "Login Failed. Please make sure username/password is correct."
            #            render :action => :new
            redirect_to new_user_sessions_path
        end
    end

    def destroy
        @user_session = current_user_session
        @user_session.destroy if @user_session
        flash[:notice] = "Sign out successful!"
#        redirect_back_or_default root_url
        redirect_to root_url
    end
end
