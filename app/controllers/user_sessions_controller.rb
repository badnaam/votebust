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
        if params[:brute_force] && params[:brute_force] == "true"
            @bf = true
        end
    end

    def create
        @user_session = UserSession.new(params[:user_session])
        if params['recaptcha_challenge_field']
            v = verify_recaptcha(:model => @user_session, :message => "Text entered did not match the image!")
        else
            v = true
        end
        if v
            if @user_session.save
                if @user_session.new_registration?
                    flash[:notice] = "Welcome! Please review your profile information before continuing"
                    #                redirect_to edit_user_path((current_user == nil) ? @user_session.record : current_user)
                    redirect_to edit_user_path(current_user)
                    cookies[:registration_complete] = false
                else
                    if @user_session.registration_complete?
                        flash[:notice] = "Welcome #{current_user.username}"
                        cookies[:registration_complete] = true
                        cookies[:voteable_user_city] = current_user.city if !current_user.city.nil?
                        session[:current_role] = current_user.role.name if current_user && !current_user.role.nil?
                        #award points for completing registration
                        redirect_back_or_default root_url
                    else
                        flash[:notice] = "Welcome back! Please complete required registration details before continuing.."
                        cookies[:registration_complete] = false
                        #                    redirect_to edit_user_path((current_user == nil) ? @user_session.record : current_user)
                        redirect_to edit_user_path(current_user)
                    end
                end
            else
                #            logger.debug @user_session.inspect
                flash[:error] = "Login Failed. Please make sure username/password is correct."
                if @user_session.being_brute_force_protected?
                    logger.info "session failed, bf"
                    @user_session.errors.clear if !@user_session.errors.nil?
                    render :action => :new
                else
                    logger.info "session failed, no bf"
                    redirect_to new_user_sessions_path
                end
                
            end
        else
            if @user_session.being_brute_force_protected?
                logger.info "recap failed, bf"
                render :action => :new
            else
                logger.info "recap failed, no bf"
                render :action => :new
#                redirect_to new_user_s essions_path
            end
        end
    end

    def destroy
        @user_session = current_user_session
        @user_session.destroy if @user_session
        session[:current_role] = nil
        cookies[:registration_complete] = nil
        session[:return_to] = nil
        flash[:notice] = "Sign out successful!"
        #        redirect_back_or_default root_url
        redirect_to root_url
    end
end
