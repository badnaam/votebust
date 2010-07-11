class VoteTopicsController < ApplicationController
    # GET /vote_topics
    # GET /vote_topics.xml
    layout "main"
    filter_access_to [:edit, :update], :attribute_check => true
    before_filter :require_user, :only => [ :new, :create]

    ########## Security hole, control access!
    
    def process_votes
        @vote_topic = VoteTopic.find(params[:id], :include => :vote_items)
        if !@vote_topic.nil? && !params[:response].nil? && !current_user.nil?
            @vote_items = @vote_topic.vote_items
            selected_response = @vote_topic.vote_items.find_by_id(params[:response])
            if !current_user.voted_for?(selected_response)
                if current_user.vote_for(selected_response)
                    flash[:success] = "Thanks for voting. Your vote is being processed."
                else
                    flash[:error] = "Something went wrong, we couldn't process your vote."
                end
            else
                flash[:notice] = "You already voted."
            end
            #initiate post processing
            @vote_topic.send_later(:post_process, selected_response, current_user)
            respond_to do |format|
                format.html
                format.js
            end
        end
    rescue
        flash[:error] = "Something went wrong, we couldn't process your vote."
    end

    def breakdown
        @bd_type = params[:bd_type] if !params[:bd_type].nil?
        @vote_topic = VoteTopic.find(params[:id])
        respond_to do |format|
            format.js
        end
    end
    
    def index
        if !params[:user_id].nil?
            @user = User.find(params[:user_id])
            @vote_topics = VoteTopic.find_all_by_user_id(params[:user_id])
        elsif !params[:category_id].nil?
            @vote_topics = VoteTopic.find_all_by_category_id(params[:category_id])
        else
            @vote_topics = VoteTopic.all
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
        @comments = @vote_topic.comments.find(:all, :order => 'created_at DESC').paginate(:page => params[:page],
            :per_page => Constants::COMMENTS_PER_PAGE)
        if !request.xhr?
            if !params[:user_id].nil?
                @user = User.find(params[:user_id]) unless params[:user_id].nil?
            else
                @user = @vote_topic.user
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
        @vote_items = @vote_topic.vote_items.build

        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @vote_topic }
        end
    end

    # GET /vote_topics/1/edit
    def edit
        @edit = true
        @user = User.find(params[:user_id])
        @vote_topic = VoteTopic.find(params[:id])

        respond_to do |format|
            format.html
        end
    end

    # POST /vote_topics
    # POST /vote_topics.xml
    def create
        @user = User.find(params[:vote_topic][:user_id].to_i)
        @vote_topic = @user.vote_topics.create(params[:vote_topic])

        respond_to do |format|
            if @vote_topic.save
                flash[:notice] = 'VoteTopic was successfully created.'
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
