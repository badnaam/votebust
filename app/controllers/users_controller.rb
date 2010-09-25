class UsersController < ApplicationController
    layout proc { |controller| ["show", "edit"].include?(controller.action_name) ? 'main' : 'login' }
    #    skip_before_filter :require_user, :only => [:top_voters]
    before_filter :require_no_user, :only => [:new, :create]
    before_filter :require_user, :except => [:new, :create, :top_voters]
    before_filter :store_location, :only => [:show]
    filter_access_to [:edit, :update], :attribute_check => true

    def new
        @user = User.new
        #        @user_session = UserSession.new
    end

    def top_voters
        @users = User.get_top_voters
        respond_to do |format|
            format.js
        end
    end
    
    def create
        @user = User.new(params[:user])
        @user.role = Role.find_by_name('user')
        @user.perishable_token = Authlogic::Random.friendly_token
        v = verify_recaptcha(:model => @user, :message => "Text entered did not match the image!")
        if v 
            if @user.save_without_session_maintenance
                flash[:notice] = t('users.create.confirmation')
                if @user.voting_power == 0
                    @user.increment!(:voting_power, Constants::REGISTRATION_COMPLETE_POINTS)
                end
                #                redirect_back_or_default root_url
                @user.delay.deliver_activation_instructions!
                redirect_to root_url
            else
                render :action => :new
            end
        else
            render :action => :new
        end
    end

    def show
        if !registration_complete?
            redirect_to edit_user_path(current_user)
        else
            @user = User.find(params[:id])
            @fim = FriendInviteMessage.new
        end
        #        @fim = current_user.friend_invite_messages.build
        
    end

    def edit
        @user = current_user
        @user.valid?
    end

    def update
        @user = current_user # makes our views "cleaner" and more consistent
        if @user.update_attributes(params[:user])
            flash[:notice] = "Account updated!"
            if @user.voting_power == 0
                @user.increment!(:voting_power, Constants::REGISTRATION_COMPLETE_POINTS)
                flash[:notice] = "Account updated!. You have earned #{Constants::REGISTRATION_COMPLETE_POINTS} Voting Power"
            else
                flash[:notice] = "Account updated!"
            end
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
