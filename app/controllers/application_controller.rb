# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    layout "main"
    
    helper :all # include all helpers, all the time
    protect_from_forgery # See ActionController::RequestForgeryProtection for details
    after_filter :discard_flash_if_xhr
    before_filter :set_current_user

    # Scrub sensitive parameters from your log
    # filter_parameter_logging :password
    helper_method :current_user_session, :current_user
    filter_parameter_logging :password, :password_confirmation

    def header_exempt
        @header_exempt_page = true
    end
    
    def permission_denied
        flash[:notice] = "Sorry, permission denied."
        respond_to do |format|
            format.html { redirect_to(:back) rescue redirect_to('/') }
            format.xml  { head :unauthorized }
            format.js   { head :unauthorized }
        end
    end

    private
    def current_role
        unless current_user.nil?
            unless current_user.role.blank?
                current_user.role.name
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
        session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
    end
end
