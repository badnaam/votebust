class UsersController < ApplicationController
    layout proc { |controller| controller.action_name == 'show' ? 'main' : 'login' }
    before_filter :require_no_user, :only => [:new, :create]
    before_filter :require_user, :except => [:new, :create]
    filter_access_to [:edit, :update], :attribute_check => true

    def new
        @user = User.new
        #        @user_session = UserSession.new
    end

    def create
        @user = User.new(params[:user])
        @user.role = Role.find_by_name('user')
        v = verify_recaptcha(:model => @user, :message => "Text entered did not match the image!")
        logger.debug v.to_s
        logger.debug @user.inspect
        logger.debug "Errors for this registration"
        logger.debug @user.errors.inspect
        if v 
            if @user.save_without_session_maintenance
                @user.send_later :deliver_activation_instructions!
                flash[:notice] = t('users.create.confirmation')
#                redirect_back_or_default root_url
                redirect_to root_url
            else
                render :action => :new
            end
        else
#            @user.errors.add()
#            flash[:error] = "Text entered did not match the image"
            render :action => :new
        end
    end

    def show
        @user = User.find(params[:id])
    end

    def edit
        @user = current_user
        @user.valid?
    end

    def update
        @user = current_user # makes our views "cleaner" and more consistent
        if @user.update_attributes(params[:user])
            flash[:notice] = "Account updated!"
            #            redirect_to current_user
            redirect_back_or_default current_user
        else
            render :action => :edit
        end
    end

    # This action has the special purpose of receiving an update of the RPX identity information
    # for current user - to add RPX authentication to an existing non-RPX account.
    # RPX only supports :post, so this cannot simply go to update method (:put)
    def addrpxauth
        @user = current_user
        if @user.save
            flash[:notice] = "Successfully added RPX authentication for this account."
            render :action => 'show'
        else
            render :action => 'edit'
        end
    end
  
end
