class ActivationsController < ApplicationController
    before_filter :require_no_user, :only => [:new, :create]
    layout 'login'
    def new
        @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)
        raise Exception if @user.active?
    end

    def create
        @user = User.find(params[:id])
        raise Exception if @user.active?

        if @user.activate!
#            @user.send_later :deliver_activation_confirmation!
            @user.delay.deliver_activation_confirmation!
            flash[:notice] = t('notifier.act_conf')
            redirect_to login_path
        else
            render :action => :new
        end
    end

end
