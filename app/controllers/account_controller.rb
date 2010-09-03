class AccountController < ApplicationController
    layout "main"
    def index
        @vote_topics = (VoteTopic.awaiting_approval).paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
        respond_to do |format|
            format.js
            format.html
        end
    end

    def approve_vote
        @vote_topic = VoteTopic.find_for_approval(params[:id])
        if current_role == 'admin'
            if !params[:vote_action].nil? && params[:vote_action] == 'deny'
                if @vote_topic.update_attribute('status', 'd')
                    @vote_topic.delay.deliver_denied_vote_notification!((VoteTopic::DENIAL).index(params[:reason].to_i))
                    flash[:success] = "Denied and Destroyed!"
                end
            else
                @vote_topic.status = 'a'
                @vote_topic.expires = 2.weeks.from_now
                if @vote_topic.save(false)
                    @vote_topic.poster.delay.award_points(@vote_topic.power_offered * -1) if !@vote_topic.power_offered.nil? &&
                      @vote_topic.power_offered > Constants::VOTING_POWER_OFFER_INCREMENT
                    @vote_topic.poster.delay.award_points(Constants::NEW_VOTE_POINTS)
                    if !@vote_topic.friend_emails.nil?
                        @vote_topic.delay.deliver_friendly_vote_emails!
                    end
                    flash[:success] = 'Changed vote status to approved'
                end
            end
        else
            flash[:error] = "Sorry can't do that"
        end
        respond_to do |format|
            format.html {redirect_to :action => :index}
            format.js
        end
    end

end
