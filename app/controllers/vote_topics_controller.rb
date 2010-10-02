class VoteTopicsController < ApplicationController
    # GET /vote_topics
    # GET /vote_topics.xml
    layout "main"
    before_filter :load_vt_from_id_and_scope, :only => [:edit, :update]
    filter_access_to [:edit, :update], :attribute_check => true
    before_filter :require_user, :only => [:edit, :new, :create]
    before_filter :store_location, :only => [:show, :index]
    before_filter :require_registration, :only => [:new, :edit, :create]
    ########## Security hole, control access!

    def rss  
        @vote_topics = VoteTopic.rss
        respond_to do |format|
            format.rss
        end
    end
    
    def auto_comp
        @search_res = VoteTopic.search :conditions => {:header => params[:term]}, :with => {:status => STATUS[:approved]}, :match_mode => :any, :limit => 10
        respond_to do |format|
            format.js
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

            if params[:city]
                if params[:limited]
                    params[:listing_type] = 'city_limited'
                else
                    params[:listing_type] = 'city'
                end
                
            elsif params[:state]
                params[:listing_type] = 'state'
            end
            
            listing_type = params[:listing_type]
            
            case listing_type
                #todo locking it down, anyone can pass tracked user?
            when "tracked_all"
                @vote_topics = VoteTopic.get_tracked_votes(current_user, false, params[:page], params[:order])
            when "user_tracked_all"
                @vote_topics = VoteTopic.get_tracked_votes(current_user, false, params[:page], params[:order])
            when "tracked"
                @vote_topics = VoteTopic.get_tracked_votes(current_user, true, nil, params[:order])
            when "city"
                @vote_topics = VoteTopic.city_search params[:city], false, params[:page], params[:order]
                cookies[:current_search_city] = params[:city]
            when "city_limited"
                @vote_topics = VoteTopic.city_search params[:city], true, nil, params[:order]
            when "state"
                @vote_topics = VoteTopic.state_search params[:state], false, params[:page], params[:order]
                cookies[:current_search_state] = params[:state]
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
                #if currrent_user then show everything
                if current_user.id == params[:user_id].to_i
                    @vote_topics = VoteTopic.get_all_votes_user_own(params[:user_id], params[:page] , params[:order])
                else
                    #show only approved
                    @vote_topics = VoteTopic.get_all_votes_user(params[:user_id], params[:page] , params[:order])
                end
            when "featured"
                @vote_topics = Rails.cache.fetch('featured_limited', :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
                    VoteTopic.get_featured_votes(true, nil, params[:order])
                end
            when "featured_all"
                @vote_topics = VoteTopic.get_featured_votes(false, params[:page], params[:order])
            when "general_limited"
                @vote_topics = VoteTopic.general_list true, nil, params[:order]
            else
                # it's "all"
                #                if stale?(:etag => "all_vote_topics_#{params[:page]}_#{params[:order]}_#{VoteTopic.ca_key}")
                @vote_topics = VoteTopic.general_list false, params[:page], params[:order]
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
        @vote_topic = VoteTopic.find_for_show(params[:id], params[:scope])
        if @vote_topic.status == VoteTopic::STATUS[:approved]
            if current_user
                @selected_response = Vote.user_voted?(current_user.id, @vote_topic.id)
            end
        else
            flash[:notice] = "This vote has not been approved yet"
            redirect_to :back
        end
        respond_to do |format|
            format.html {

            }# show.html.erb
            #            format.js
            #            format.xml  { render :xml => @vote_topic }
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
            @vote_topics = VoteTopic.city_search cookies[:current_search_city], true, nil, 'tracking'
        when "most_tracked_state"
            @vote_topics = VoteTopic.state_search cookies[:current_search_state], true, nil, 'tracking'
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
        @vote_items = 2.times {@vote_topic.vote_items.build}

        respond_to do |format|
            format.html # new.html.erb
            format.js {}
            format.xml  { render :xml => @vote_topic }
        end
    end

    # GET /vote_topics/1/edit
    def edit
        #allow edits if it hasn't been approved yet
        if !@vote_topic.status == VoteTopics::STATUS[:approved]
            @edit = true
            @saved = true
        end
        respond_to do |format|
            format.html {
                if @edit
                    #
                    setup_vote_items(true)
                else
                    flash[:error] = 'Sorry no further edits, Vote has already been approved.'
                    redirect_back_or_default root_url
                end
            }
            format.js {
                if !@edit
                    flash[:error] = 'Sorry no further edits, Vote has already been approved.'
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
        @vote_topic.status = VoteTopic::STATUS[:nw]
        respond_to do |format|
            if @vote_topic.save
                @saved = true
                flash[:success] = "Your vote was saved and sent for moderator approval. You can check it's status in your profile page."
                format.html { redirect_to root_path }
                format.js {}
                format.xml  { render :xml => @vote_topic, :status => :created, :location => @vote_topic }
            else
                @vote_items = 2.times {@vote_topic.vote_items.build}
                format.html { render :action => "new", :not_saved => true }
                format.js {
                    @not_saved = true
                    render :action => "new"}
                format.xml  { render :xml => @vote_topic.errors, :status => :unprocessable_entity }
            end
        end
    end

    # PUT /vote_topics/1
    # PUT /vote_topics/1.xml
    def update
        @vote_topic = VoteTopic.find(params[:id], :scope => params[:scope])
        #todo - take care of someone fucking with the power offered
        params[:vote_topic].keys.each do |k|
            @vote_topic.send("#{k}=", params[:vote_topic][k])
        end
        respond_to do |format|
            if @vote_topic.status == VoteTopic::STATUS[:nw]
                @vote_topic.status = VoteTopic::STATUS[:revised]
            end
            if @vote_topic.save
                #increase edit count so we can refresh the user owned vote_topics cache
                @vote_topic.poster.increment!(:edit_count, 1)
                flash[:notice] = 'VoteTopic was successfully updated.'
                #kill the cache
                Rails.cache.delete("vt_#{@vote_topic.id}")
                @saved = true
                #todo figure out where to redirect
                format.html {redirect_back_or_default root_path}
                #                format.html { redirect_to scoped_vote_topic_path(@vote_topic.category, @vote_topic)}
                format.xml  { head :ok }
                format.js{}
            else
                @edit = true
                @saved = false
                format.html { render :action => "edit" }
                format.xml  { render :xml => @vote_topic.errors, :status => :unprocessable_entity }
                format.js{render :action => "edit"}
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
