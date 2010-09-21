class VoteTopicsController < ApplicationController
    # GET /vote_topics
    # GET /vote_topics.xml
    layout "main"
    before_filter :load_vt_from_id_and_scope, :only => [:edit, :update]
    filter_access_to [:edit, :update, :confirm_vote], :attribute_check => true
    before_filter :require_user, :only => [:edit, :new, :create, :approve_vote, :track]
    before_filter :store_location, :only => [:show]
    before_filter :require_registration, :only => [:new, :edit, :create]
    ########## Security hole, control access!

    def rss  
        @vote_topics = VoteTopic.rss
        respond_to do |format|
            format.rss
        end
    end
    
    def auto_comp
        @search_res = VoteTopic.search :conditions => {:header => params[:term]}, :with => {:status => 'a'}, :match_mode => :any, :limit => 10
        respond_to do |format|
            format.js
        end
    end
    
    
    def approve_vote
        @vote_topic = VoteTopic.find(params[:id])
        if current_role == 'admin'
            @vote_topic.status = 'a'
            @vote_topic.expires = 2.weeks.from_now
            if @vote_topic.save
                flash[:success] = 'Change vote status to approved'
            end
        else
            flash[:error] = "Sorry can't do that"
        end
        respond_to do |format|
            format.html {redirect_to :controller => :account, :action => :index}
            format.js 
        end
    end

    def update_stats
        @user = params[:user_id].blank? ? false : true
        @reg_complete = params[:reg_complete] if !params[:reg_complete].blank?
        
        @vote_topic = VoteTopic.find_for_stats(params[:id])
        #just use the id
        if @vote_topic.expires > DateTime.now
            @vote_open = true
        end
        respond_to do |format|
            format.js
        end
    end
    

    def confirm_vote
        @vote_topic = VoteTopic.find(params[:id])
        if @vote_topic.update_attribute(:status, 'w')
            flash[:notice] = 'Vote was successfully created and sent for moderator approval.'
            @vote_topic.delay.deliver_new_vote_notification!
        else
            flash[:error] = 'Something went wrong.'
        end
        respond_to do |format|
            #            format.html { redirect_to(:action => :show, :id => @vote_topic.id, :waiting => true) }
            format.html { redirect_to root_path }
        end
    end
    
    def index
        #        expires_in 10.minutes, :public => true
        if request.parameters[:order].nil?
            request.parameters.merge!({:order => 'recent'})
        end

        if request.parameters[:page].nil?
            request.parameters.merge!({:page => 1})
        end

        if params[:category_id]
            @vote_topics = (VoteTopic.category_list params[:category_id], params[:page], params[:order])
        else
            listing_type = params[:listing_type]
            
            case listing_type
                #todo locking it down, anyone can pass tracked user?
            when "tracked_all"
                @vote_topics = VoteTopic.get_tracked_votes(current_user, false, params[:page], params[:order])
            when "user_tracked_all"
                @vote_topics = VoteTopic.get_tracked_votes(current_user, false, params[:page], params[:order])
            when "tracked"
                @vote_topics = VoteTopic.get_tracked_votes(current_user, true, nil, params[:order])
            when "top"
                #                if stale?(:etag => Datetime.now.utc + )
                @vote_topics = Rails.cache.fetch('top_limited', :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
                    (VoteTopic.get_top_votes true, params[:page], params[:order])
                end
                #                end
            when "top_all"
                @vote_topics = VoteTopic.get_top_votes false, params[:page] || 1,  params[:order]
            when "most_tracked"
                @vote_topics = Rails.cache.fetch('most_tracked_limited', :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
                    VoteTopic.get_most_tracked_votes true, nil, params[:order]
                end
            when "most_tracked_all"
                @vote_topics =  VoteTopic.get_most_tracked_votes false, params[:page], params[:order]
            when "user_all"
                @vote_topics = VoteTopic.get_all_votes_user(params[:user_id], params[:page] , params[:order])
            when "featured"
                @vote_topics = Rails.cache.fetch('featured_limited', :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
                    VoteTopic.get_featured_votes(true, nil, params[:order])
                end
            when "featured_all"
                @vote_topics = VoteTopic.get_featured_votes(false, params[:page], params[:order])
            else
                # it's "all"
                #                if stale?(:etag => "all_vote_topics_#{params[:page]}_#{params[:order]}_#{VoteTopic.ca_key}")
                @vote_topics = VoteTopic.general_list params[:page], params[:order]
                #                end
            end
        end

        #        respond_to do |format|
        #            format.html # index.html.erb
        #            format.js
        ##            format.xml  { render :xml => @vote_topics }
        #        end
    end

    # GET /vote_topics/1
    # GET /vote_topics/1.xml
    def show
        if params[:preview_only] == 'true'
            #todo :optimize this
            @vote_topic = VoteTopic.find_for_preview_save(params[:id])
            @user = current_user
        else
            @vote_topic = VoteTopic.find_for_show(params[:id], params[:scope])
            if current_user
                @selected_response = Vote.user_voted?(current_user.id, @vote_topic.id)
            end
        end
        
        respond_to do |format|
            format.html # show.html.erb
            format.js
            format.xml  { render :xml => @vote_topic }
        end
    end

    def side_bar_index
        listing_type = params[:type]
        
        case listing_type
        when "same_category"
            @vote_topics = VoteTopic.get_same_category params[:category_id]
        when "latest"
            @vote_topics = VoteTopic.get_latest
        when "unan"
            @vote_topics = VoteTopic.get_unanimous_vote_topics
        when "same_user"
            @vote_topics = VoteTopic.get_more_from_same_user params[:user_id]
        when "top_votes_min"
            @vote_topics = VoteTopic.get_top_votes_minimal
            #todo the following is no good if cookies are disabled
        when "most_tracked_city"
            @vote_topics = Search.city_search cookies[:current_search_city], Constants::SIDEBAR_LISTING_NUM, 1, 'tracking'
        when "most_tracked_state"
            @vote_topics = Search.state_search cookies[:current_search_state], Constants::SIDEBAR_LISTING_NUM, 1, 'tracking'
        end
        respond_to do |format|
            format.js
        end
    end
    
    # GET /vote_topics/new
    # GET /vote_topics/new.xml
    def new
        @user = current_user
        @vote_topic = @user.posted_vote_topics.build
        @vote_items = VoteTopic::MAX_VOTE_ITEMS.times {@vote_topic.vote_items.build}

        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @vote_topic }
        end
    end

    # GET /vote_topics/1/edit
    def edit
        @user = current_user

#        @vote_topic = VoteTopic.find(params[:id], :scope => params[:scope])
#        @vote_topic = VoteTopic.find(params[:id], :scope => params[:scope])
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
        #        @vote_topic = current_user.posted_vote_topics.create(params[:vote_topic])
        @vote_topic = VoteTopic.create(params[:vote_topic])
        @vote_topic.user_id = current_user.id
        @vote_topic.status = 'p'
        respond_to do |format|
            if @vote_topic.save
                format.html { redirect_to vote_topic_path(@vote_topic.id, :preview_only => true) }
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
        @vote_topic = VoteTopic.find(params[:id], :scope => params[:scope])
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

    protected
    
    def load_vt_from_id_and_scope
        @vote_topic = VoteTopic.find(params[:id], :scope => params[:scope])
    end
end
