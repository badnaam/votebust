class UsersController < ApplicationController
    layout "main"
    before_filter :require_no_user, :only => [:new, :create]
    before_filter :require_user, :only => [:show, :edit, :update]
    filter_access_to [:edit, :update], :attribute_check => true

    def new
        @user = User.new
    end

    def create
        @user = User.new(params[:user])
        @user.role = Role.find_by_name('user')
        v = verify_recaptcha(:model => @user, :message => "Image verification failure!")
        if v & @user.save_without_session_maintenance
            @user.send_later :deliver_activation_instructions!
            flash[:notice] = t('users.create.confirmation')
            redirect_back_or_default root_url
        else
            render :action => :new
        end
    end

    def show
        @user = User.find(params[:id])
    end

    def edit
        @user = @current_user
    end

    def update
        @user = @current_user # makes our views "cleaner" and more consistent
        if @user.update_attributes(params[:user])
            flash[:notice] = "Account updated!"
            redirect_to current_user
        else
            render :action => :edit
        end
    end
end
