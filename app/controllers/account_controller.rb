class AccountController < ApplicationController
    layout "main"
    before_filter :require_user
    before_filter :site_admin_only
    
    def index
        respond_to do |format|
            format.html
        end
    end

    def daily_comments
        @comments = Comment.daily_comments.paginate(:page => (params[:page] || 1), :per_page => 100)
        respond_to do |format|
            format.html
        end
    end
    def not_approved_votes
        @vote_topics = (VoteTopic.awaiting_approval).paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
        respond_to do |format|
            format.html
        end
    end
    def not_approved_comments
        @comments = Comment.not_approved.paginate(:page => (params[:page] || 1), :per_page => 100)
        respond_to do |format|
            format.html
        end
    end
    
    def reject_vote
        @vote_topic = VoteTopic.find(params[:id])
        if @vote_topic.update_attribute('status', VoteTopic::STATUS[:denied])
            @vote_topic.delay.deliver_denied_vote_notification!((VoteTopic::DENIAL).index(params[:reason].to_i))
            @vote_topic.delay.post_save_processing("denied")
            flash[:success] = "Denied and Destroyed!"
        end
        #todo cache delete
        Rails.cache.delete("vt_#{@vote_topic.id}")
        respond_to do |format|
            format.html {redirect_to not_approved_votes_account_path}
        end
    end
    
    def approve_vote
        @vote_topic = VoteTopic.find(params[:id])
        # if it's a revision just approve, no power and no extension, still expires in 2 weeks
        if do_approve
            flash[:success] = "Approved vote to status #{@vote_topic.status}"
        else
            flash[:error] = "Something went wrong"
        end
        ## todo cache delete refresh the cache
        Rails.cache.delete("vt_#{@vote_topic.to_param}")
        respond_to do |format|
            format.html {redirect_to not_approved_votes_account_path}
            format.js
        end
    end

    def reject_comments
        if Comment.destroy(params[:comment_ids])
            flash[:success] = "Destroyed spam comments"
        else
            flash[:error] = "Somehting went wrong"
        end
        respond_to do |format|
            format.html {redirect_to :back}
        end
    end
    
    def approve_comment
        if params[:daily]
            redirect_path = daily_comments_account_path
        else
            redirect_path = not_approved_comments_account_path
        end
        @comment = Comment.find(params[:id])
        if @comment.update_attribute(:approved, true)
            @comment.ham!
            flash[:success] = "Marked Comment as approved"
        else
            flash[:error] = "Something went wrong"
        end
        respond_to do |format|
            format.html {redirect_to redirect_path}
        end
    end

    def reject_comment
        @comment = Comment.find(params[:id])
        if params[:daily]
            begin
                @comment.spam!
            rescue => exp
            end
            redirect_path = daily_comments_account_path
        else
            redirect_path = not_approved_comments_account_path
        end
        if @comment.destroy
            flash[:success] = "Destroyed Comment"
        end
        respond_to do |format|
            format.html {
                redirect_to redirect_path
            }
        end
    end

    private
    
    def do_approve
        @vote_topic.status = VoteTopic::STATUS[:approved]
        if @vote_topic.expires.nil?
            @vote_topic.expires = 2.weeks.from_now
            @vote_topic.increment(:edit_count, 1)
            if @vote_topic.save
                if @vote_topic.status != VoteTopic::STATUS[:revised]
                    @vote_topic.delay.post_save_processing "approved"
                end
            end
        end
    end
end
