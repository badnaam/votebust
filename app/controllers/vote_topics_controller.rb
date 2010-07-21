class VoteTopicsController < ApplicationController
    # GET /vote_topics
    # GET /vote_topics.xml
    layout "main"
    filter_access_to [:edit, :update, :confirm_vote], :attribute_check => true
    before_filter :require_user, :only => [ :new, :create, :process_votes, :cancel_vote, :approve_vote]
    #    cache_sweeper :home_sweeper, :only => [:create]
    ########## Security hole, control access!

    def approve_vote
        @vote_topic = VoteTopic.find(params[:id])
        if current_role == 'admin'
            @vote_topic.status = 'a'
            if @vote_topic.save
                flash[:success] = 'Change vote status to approved'
            end
        else
            flash[:error] = "Sorry can't do that"
        end
        respond_to do |format|
            format.html {redirect_to :controller => :account, :action => :index}
        end
    end

    def cancel_vote
        @vote_topic = VoteTopic.find(params[:id])
        @vote_items = @vote_topic.get_sorted_vi
        @selected_option = @vote_topic.what_vi_user_voted_for(current_user)
        if Vote.find_by_voteable_id_and_voter_id(@selected_option.id, current_user.id).destroy
            flash[:success] = "Your vote has been cancelled."
            @vote_topic.send_later(:post_process, @selected_response, current_user, false)
        end
        respond_to do |format|
            format.js
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
            format.html { redirect_to(@vote_topic) }
        end
    end
    
    def process_votes
        @vote_topic = VoteTopic.find(params[:id])
        if !@vote_topic.nil? && !params[:response].nil? && !current_user.nil?
            @vote_items = @vote_topic.get_sorted_vi
            @selected_response = @vote_topic.vote_items.find_by_id(params[:response])
            if !current_user.voted_for?(@selected_response)
                if current_user.vote_for(@selected_response)
                    flash[:success] = "Thanks for voting. Your vote is being processed."
                else
                    flash[:error] = "Something went wrong, we couldn't process your vote."
                end
            else
                flash[:notice] = "You already voted."
            end
            #initiate post processing
            @vote_topic.send_later(:post_process, @selected_response, current_user, true)
            respond_to do |format|
                format.html
                format.js
            end
        end
    rescue
        flash[:error] = "Something went wrong, we couldn't process your vote."
    end

    
    def index
        if !params[:user_id].nil?
            @user = User.find(params[:user_id])
            @vote_topics = @user.vote_topics
        elsif !params[:category_id].nil?
            @category = Category.find(params[:category_id])
            #            @vote_topics = VoteTopic.find_all_by_category_id(params[:category_id])
            @vote_topics = @category.vote_topics.status_equals('a')
        else
            @vote_topics = VoteTopic.status_equals('a')
        end
        respond_to do |format|
            format.html # index.html.erb
            format.xml  { render :xml => @vote_topics }
        end
    end

    # GET /vote_topics/1
    # GET /vote_topics/1.xml
    def show
        @vote_topic = VoteTopic.find(params[:id])
        if params[:comment_only] == "true"
            @comments = @vote_topic.comments.find(:all, :order => 'created_at DESC').paginate(:page => params[:page],
                :per_page => Constants::COMMENTS_PER_PAGE)
        else
            if @vote_topic.status == 'a'
                @approved = true
                @vote_items = @vote_topic.get_sorted_vi
                @p_chart = @vote_topic.make_flash_pie_graph(true)
                @comments = @vote_topic.comments.find(:all, :order => 'created_at DESC').paginate(:page => params[:page],
                    :per_page => Constants::COMMENTS_PER_PAGE)
                @selected_response = @vote_topic.what_vi_user_voted_for(current_user) if current_user
                #Gather related
                @related = VoteTopic.search "", :with => {:category_id => @vote_topic.category_id},
                  :order => :created_at, :sort_mode => :desc, :limit => Constants::SMART_COL_LIMIT
                @same_user = VoteTopic.search "", :with => {:user_id => @vote_topic.user_id},
                  :order => :created_at, :sort_mode => :desc, :limit => Constants::SMART_COL_LIMIT
            elsif @vote_topic.status == 'p'
                @preview = true
                @vote_items = @vote_topic.vote_items
            elsif @vote_topic.status == 'w'
                @waiting = true
                flash[:notice] = "This vote will be displayed after moderator approval."
            end
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
#        @vote_items = @vote_topic.vote_items.build
        @vote_items = 5.times {@vote_topic.vote_items.build}

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
              
                format.html { redirect_to(@vote_topic) }
                format.xml  { render :xml => @vote_topic, :status => :created, :location => @vote_topic }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @vote_topic.errors, :status => :unprocessable_entity }
            end
        end
    end

    # PUT /vote_topics/1
    # PUT /vote_topics/1.xml
    def update
        @vote_topic = VoteTopic.find(params[:id])

        respond_to do |format|
            params[:vote_topic][:status] = 'p'
            if @vote_topic.update_attributes(params[:vote_topic])
                flash[:notice] = 'VoteTopic was successfully updated.'
                format.html { redirect_to(@vote_topic) }
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
end
