# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class ApplicationController < ActionController::Base
    layout "main"
#    include ExceptionNotification::Notifiable
    before_filter :admin_only
    
    helper :all # include all helpers, all the time
    #    protect_from_forgery # See ActionController::RequestForgeryProtection for details
    after_filter :discard_flash_if_xhr
    #    before_filter :set_current_user

    # Scrub sensitive parameters from your log
    # filter_parameter_logging :password
    helper_method :current_user_session, :current_user, :current_role, :registration_complete?, :site_admin_only
    filter_parameter_logging :password, :password_confirmation

    EXCEPTIONS_NOT_LOGGED = ['ActionController::UnknownAction',
        'ActionController::RoutingError']
    include ModelHelpers
    
    def log_error(exc)
        super unless EXCEPTIONS_NOT_LOGGED.include?(exc.class.name)
    end
    
    def permission_denied
        flash[:error] = "Sorry, permission denied."
        respond_to do |format|
            format.html { redirect_to(:back) rescue redirect_to('/') }
            format.xml  { head :unauthorized }
            format.js   { head :unauthorized }
        end
    end

    private
    
    def site_admin_only
        if current_role == 'admin'
            return true
        else
            flash[:error] = "Sorry, permission denied."
            respond_to do |format|
                format.html { redirect_to(:back) rescue redirect_to('/') }
                format.xml  { head :unauthorized }
                format.js   { head :unauthorized }
            end
        end
    end
    
    def admin_only
        if Rails.env == "production"
            authenticate_or_request_with_http_basic do |id, password|
                id == APP_CONFIG["http_user"] && password == APP_CONFIG["http_pwd"]
            end
        end
    end
    
    def current_role
        unless current_user.nil?
            if session[:current_role]
                session[:current_role]
            else
                unless current_user.role.blank?
                    current_user.role.name
                end
            end
        end
    end

    def discard_flash_if_xhr
        flash.discard if request.xhr?
    end
    
    def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
    end

    def set_current_user
        Authorization.current_user = current_user
    end
    
    def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.record
    end

    def registration_complete?
        current_user_session.registration_complete? if current_user_session
    end

    def require_registration
        unless registration_complete?
            store_location
            flash[:notice] = "Please complete registration before continuing"
            redirect_to edit_user_path(current_user)
        end
    end
    
    def require_user
        unless current_user
            store_location
            flash[:notice] = "You must be logged in to access this page"
            redirect_to new_user_sessions_url
            return false
        end
    end

    def require_no_user
        if current_user
            store_location
            flash[:notice] = "You must be logged out to access this page"
            redirect_to account_url
            return false
        end
    end

    def store_location
        if !request.xhr?
            session[:return_to] = request.request_uri
        end
    end

    def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
    end
end
