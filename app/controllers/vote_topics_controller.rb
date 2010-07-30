class VoteTopicsController < ApplicationController
    # GET /vote_topics
    # GET /vote_topics.xml
    layout "main"
    filter_access_to [:edit, :update, :confirm_vote], :attribute_check => true
    before_filter :require_user, :only => [ :new, :create, :process_votes, :cancel_vote, :approve_vote]
    before_filter :store_location, :only => [:show]
    #    cache_sweeper :home_sweeper, :only => [:create]
    ########## Security hole, control access!

    def approve_vote
        @vote_topic = VoteTopic.find(params[:id])
        if current_role == 'admin'
            @vote_topic.status = 'a'
            if @vote_topic.save
                if !@vote_topic.friend_emails.nil?
                    @vote_topic.send_later :deliver_friendly_vote_emails!
                end
                flash[:success] = 'Change vote status to approved'
            end
        else
            flash[:error] = "Sorry can't do that"
        end
        respond_to do |format|
            format.html {redirect_to :controller => :account, :action => :index}
        end
    end

    def update_stats
        @vote_topic = VoteTopic.find_for_stats(params[:id])
        @reg_complete = params[:reg_complete]
        if @vote_topic.total_votes > 0
            @user = User.find_by_id(params[:user_id], :select => :id) if !params[:user_id].nil?
            if !params[:sel_response].blank?
                @selected_response = VoteItem.find(params[:sel_response]) 
            end
            @p_chart = @vote_topic.make_flash_pie_graph(true)
        end
        respond_to do |format|
            format.js
        end
    end
    
    def cancel_vote
        @user = User.find(params[:user_id], :select => "users.id, users.processing_vote, users.persistence_token, users.sex, users.age, users.username")
        if @user.processing_vote == false
            @selected_response = VoteItem.find(params[:sel_response], :include => [:vote_topic],:select => "vote_topics.header, vote_topics.id, vote_topics.total_votes, vote_items.id, vote_items.option, ag_1_v, ag_2_v, ag_3_v, ag_4_v, male_votes, female_votes")
            @vote_topic = @selected_response.vote_topic
            @reg_complete = params[:reg_complete]
            if Vote.find(:first, :conditions => ['voteable_id = ? AND voter_id = ?', @selected_response.id, @user.id]).destroy && @vote_topic.decrement!(:total_votes, 1)
                flash[:success] = "Your vote has been cancelled."
                @user.update_attribute(:processing_vote, true)
                @vote_topic.send_later(:post_process, @selected_response, @user, false)
            end
        else
            flash[:notice] = "Please wait while we process your previous vote"
        end
        respond_to do |format|
            format.js
        end
    end

    def process_votes
        @user = User.find(params[:user_id], :select => "users.id, users.processing_vote, users.persistence_token, users.age, users.sex, users.username")
        @reg_complete = params[:reg_complete]
        if @user.processing_vote == false
            if  !params[:response].nil? && !@user.nil?
                @selected_response = VoteItem.find(params[:response], :include => [:vote_topic],:select => "vote_topics.header, vote_topics.id, vote_topics.total_votes, vote_items.id, vote_items.option, ag_1_v, ag_2_v, ag_3_v, ag_4_v, male_votes, female_votes")
                @vote_topic = @selected_response.vote_topic
                if !@user.voted_for?(@selected_response)
                    if @user.vote_for(@selected_response) && @vote_topic.increment!(:total_votes, 1)
                        flash[:success] = "Thanks for voting. Your vote is being processed."
                    else
                        flash[:error] = "Something went wrong, we couldn't process your vote."
                    end
                else
                    flash[:notice] = "You already voted."
                end
                #initiate post processing
                @user.update_attribute(:processing_vote, true)
                @vote_topic.send_later(:post_process, @selected_response, @user, true)
            else
                flash[:notice] = "Please wait while we process your previous vote"
            end
            respond_to do |format|
                format.html
                format.js
            end
        end
    end


    def confirm_vote
        @vote_topic = VoteTopic.find(params[:id])
        if @vote_topic.update_attribute(:status, 'w')
            flash[:notice] = 'Vote was successfully created and sent for moderator approval.'
            @vote_topic.send_later :deliver_new_vote_notification!
        else
            flash[:error] = 'Something went wrong.'
        end
        respond_to do |format|
            format.html { redirect_to(:action => :show, :id => @vote_topic.id, :waiting => true) }
        end
    end
    
    
    
    def index
        if !params[:user_id].nil?
            @user_listing = true
            user = User.find(params[:user_id])
            @result_set = VoteTopic.get_all_votes_user(user) #todo : pagination?
            @vote_topics = @result_set.keys.sort_by {|k| k.total_votes}.paginate(:page => params[:page], :per_page => 2)
        elsif !params[:category_id].nil?
            @category_listing = true
            #            @vote_topics = (VoteTopic.by_category_listing params[:category_id]).paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
            @vote_topics = (VoteTopic.category_list params[:category_id], params[:page])
        else
            @general_listing = true
            #            @vote_topics = VoteTopic.all_approved.paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
            #            @vote_topics = VoteTopic.status_equals('a').descend_by_created_at(:include => [{:vote_items => :votes}, :user, :category]).paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
            #           @vote_topics = VoteTopic.status_equals('a').descend_by_created_at(:joins => [{:vote_items => :votes}, :user, :category]).paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
            #            @vote_topics = VoteTopic.find(:all, :conditions => ['status = ?', 'a'], :order => 'created_at DESC', :include => [{:vote_items => :votes}, :user, :category]).paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
            #            @vote_topics = VoteTopic.paginate(:conditions => ['status = ?', 'a'], :order => 'created_at DESC', :include => [{:vote_items => :votes}, :user, :category], :page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
            #            @vote_topics = VoteTopic.find(:all, :conditions => ['status = ?', 'a'], :order => 'created_at DESC', :joins => [{:vote_items => :votes}, :user, :category]).paginate(:page => params[:page], :per_page => Constants::LISTINGS_PER_PAGE)
            @vote_topics = VoteTopic.general_list params[:page]
        end
        respond_to do |format|
            format.html # index.html.erb
            format.js
            format.xml  { render :xml => @vote_topics }
        end
    end

    # GET /vote_topics/1
    # GET /vote_topics/1.xml
    def show
        @status = ""
        if params[:comment_only] == "true"
            @vote_topic = VoteTopic.find_for_comments(params[:id])
            @comments = @vote_topic.comments(:order => 'created_at DESC').paginate(:page => params[:page],
                :per_page => Constants::COMMENTS_PER_PAGE)
        elsif params[:preview_only] == 'true'
            @vote_topic = VoteTopic.find(params[:id])
            @user = User.find(params[:user_id])
            if @vote_topic.status == 'p'
                @status = 'preview'
            end
        elsif params[:waiting] == 'true'
            #            @vote_topic = VoteTopic.find(params[:id])
        else
            @vote_topic = VoteTopic.find_for_show(params[:id])
            @user = current_user
            @reg_complete = registration_complete?
            @status = 'approved'
            @p_chart = @vote_topic.make_flash_pie_graph(true) #only get this if total_votes > 0?
            @comments = @vote_topic.comments.paginate(:page => params[:page],
                :per_page => Constants::COMMENTS_PER_PAGE, :order => 'created_at DESC', :include => {:user => :votes})
            @selected_response = @vote_topic.what_vi_user_voted_for(@user) if @user #todo : persist this?
            #Gather related
            @related = VoteTopic.search "", :with => {:category_id => @vote_topic.category_id},
              :order => :created_at, :sort_mode => :desc, :limit => Constants::SMART_COL_LIMIT
            @same_user = VoteTopic.search "", :with => {:user_id => @vote_topic.user_id},
              :order => :created_at, :sort_mode => :desc, :limit => Constants::SMART_COL_LIMIT
        end
        
        respond_to do |format|
            format.html # show.html.erb
            format.js
            format.xml  { render :xml => @vote_topic }
        end
    end

    # GET /vote_topics/new
    # GET /vote_topics/new.xml
    def new
        @user = User.find(params[:user_id])
        @vote_topic = @user.vote_topics.build
        #        @vote_items = 5.times {@vote_topic.vote_items.build}
        @vote_items = VoteTopic::MAX_VOTE_ITEMS.times {@vote_topic.vote_items.build}

        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @vote_topic }
        end
    end

    # GET /vote_topics/1/edit
    def edit
        @user = User.find(params[:user_id])
        @vote_topic = VoteTopic.find(params[:id])
        
        if @vote_topic.status == 'p'
            edit = true
        end
        respond_to do |format|
            format.html {
                if edit
                    #
                    setup_vote_items(true)
                else
                    flash[:error] = 'Can not edit an active vote.'
                    redirect_back_or_default root_url
                end
            }
        end
    end

    # POST /vote_topics
    # POST /vote_topics.xml
    def create
        @user = User.find(params[:vote_topic][:user_id].to_i)
        @vote_topic = @user.vote_topics.create(params[:vote_topic])
        @vote_topic.status = 'p'
        respond_to do |format|
            if @vote_topic.save
                format.html { redirect_to(:action => :show, :id => @vote_topic.id, :preview_only => true, :user_id => @user.id) }
                format.xml  { render :xml => @vote_topic, :status => :created, :location => @vote_topic }
            else
                full_counter = 0
                (0..(VoteTopic::MAX_VOTE_ITEMS - 1)).each do |i|
                    if !params[:vote_topic][:vote_items_attributes][i.to_s][:option].blank?
                        full_counter += 1
                    end
                end
                if full_counter == 0
                    @vote_items = VoteTopic::MAX_VOTE_ITEMS.times {@vote_topic.vote_items.build}
                else
                    @vote_items = (VoteTopic::MAX_VOTE_ITEMS - full_counter).times {@vote_topic.vote_items.build}
                end
                format.html { render :action => "new" }
                format.xml  { render :xml => @vote_topic.errors, :status => :unprocessable_entity }
            end
        end
    end

    # PUT /vote_topics/1
    # PUT /vote_topics/1.xml
    def update
        @vote_topic = VoteTopic.find(params[:id])
        @user = User.find(params[:vote_topic][:user_id].to_i)
        respond_to do |format|
            params[:vote_topic][:status] = 'p'
            if @vote_topic.update_attributes(params[:vote_topic])
                flash[:notice] = 'VoteTopic was successfully updated.'
                format.html { redirect_to(:action => :show, :id => @vote_topic.id, :preview_only => true, :user_id => @user.id) }
                format.xml  { head :ok }
            else
                format.html { render :action => "edit" }
                format.xml  { render :xml => @vote_topic.errors, :status => :unprocessable_entity }
            end
        end
    end

    # DELETE /vote_topics/1
    # DELETE /vote_topics/1.xml
    def destroy
        @vote_topic = VoteTopic.find(params[:id])
        @vote_topic.destroy

        respond_to do |format|
            format.html { redirect_to(vote_topics_url) }
            format.xml  { head :ok }
        end
    end

    private
    def setup_vote_items( is_edit)
        if is_edit
            full_counter = @vote_topic.vote_items.length
            
            if full_counter == 0
                @vote_items = VoteTopic::MAX_VOTE_ITEMS.times {@vote_topic.vote_items.build}
            else
                @vote_items = (VoteTopic::MAX_VOTE_ITEMS - full_counter).times {@vote_topic.vote_items.build}
            end
        end
    end
end
