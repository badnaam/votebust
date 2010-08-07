require 'rubygems'
include ActionView::Helpers::TextHelper

class VoteTopic < ActiveRecord::Base
    MAX_VOTE_ITEMS = 5
    STATUS = {'approved' => 'a', 'waiting' => 'w', 'preview' => 'p'}
    FACET_KEYS = {'m' => "Men vote for ", 'w' => "Women vote for ", 'ag1' => "Voters aged between #{Constants::AGE_GROUP_1.first} - #{Constants::AGE_GROUP_1.last} vote for",
        'ag2' => "Voters aged between  #{Constants::AGE_GROUP_2.first} - #{Constants::AGE_GROUP_2.last} vote for",
        'ag3' => "Voters aged between  #{Constants::AGE_GROUP_3.first} - #{Constants::AGE_GROUP_3.last} vote for",
        'ag4' => "Voters aged between  #{Constants::AGE_GROUP_4.first} - #{Constants::AGE_GROUP_4.last} vote for"
    }
    #    belongs_to :user
    belongs_to :poster, :class_name => "User", :foreign_key => :user_id
    has_many :trackings, :dependent => :destroy
    has_many :users, :through => :tracking
    has_many :vote_facets
    belongs_to :category
    
    
    has_many :comments
    has_many :vote_items, :dependent => :destroy
    has_many :votes, :through => :vote_items

    acts_as_mappable :through => :poster

    #\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b
    validates_presence_of :header, :message => "Topic can not be blank"
    validates_presence_of :category, :message => "Please select a category"
    validates_length_of :header, :maximum => Constants::MAX_VOTE_HEADER_LENGTH,
      :message => "Please keep the topic description within #{Constants::MAX_VOTE_HEADER_LENGTH} characters"
    validates_length_of :topic, :maximum => Constants::MAX_VOTE_TOPIC_LENGTH, :allow_nil => true,
      :message => "Please keep the details within #{Constants::MAX_VOTE_TOPIC_LENGTH} characters"
    validates_length_of :website, :maximum => Constants::MAX_VOTE_EXT_LINK_LENGTH, :allow_nil => true,
      :message => "Please keep the link within #{Constants::MAX_VOTE_EXT_LINK_LENGTH} characters or make it short at http://tinyurl.com/"
    validates_length_of :friend_emails, :maximum => Constants::MAX_VOTE_TOPIC_FEMAILS, :allow_nil => true,
      :message => "Please keep the emails within #{Constants::MAX_VOTE_TOPIC_FEMAILS} characters."
    validate :valid_email?
    validate :min_vote_items, :if => :its_new?
    accepts_nested_attributes_for :vote_items, :limit => 5, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:option].blank? }

    after_destroy :destroy_graphs
    attr_accessible :topic, :header, :vote_items_attributes, :friend_emails, :anon, :header, :category_id, :website
    #    has_friendly_id :header, :use_slug => true, :approximate_ascii => true, :max_length => 50, :cache_column => :cached_slug
    
    scope_procedure :latest_votes, lambda {status_equals(STATUS['approved']).created_at_gte(
            Constants::SMART_COL_LATEST_LIMIT.ago).descend_by_created_at.descend_by_total_votes(:limit => Constants::SMART_COL_LIMIT,
            :select => "id, header, total_votes, created_at") }
    scope_procedure :awaiting_approval, lambda {status_equals(STATUS['waiting']).ascend_by_created_at}


    def is_being_tracked? id
        self.trackings.find(:first, :conditions => ['user_id = ?', id])
    end
    
    def self.unanimous_votes
        find(:all, :conditions => {:unan => true}, :order => 'created_at DESC', :limit => Constants::SMART_COL_LIMIT, :select => 'id, header, unan')
    end
    
    def self.category_list cid, page
        coll = paginate(:conditions => ['status = ? AND category_id = ?', 'a', cid], :order => 'vote_topics.created_at DESC', :include => [{:vote_items => :votes},
                :poster, :category], :page => page, :per_page => Constants::LISTINGS_PER_PAGE, :select => 'vote_topics.id, vote_topics.header, vote_topic.topic,
                vote_topics.user_id, vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes, categories.id, categories.name, vote_topics.anon,
                 users.id, users.username, vote_items.option')
        sort_collection_vote_items coll
    end

    def self.general_list page
        coll = paginate(:conditions => ['status = ?', 'a'], :order => 'vote_topics.created_at DESC', :include => [{:vote_items => :votes}, :poster, :category],
            :page => page, :per_page => Constants::LISTINGS_PER_PAGE, :select => ' vote_topics.id, vote_topics.header, vote_topic.topic, vote_topics.user_id,
            vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id, users.username,
             vote_items.option')
        sort_collection_vote_items coll
    end

    def self.find_for_processing(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [{:vote_items => :votes}])
    end
    def self.find_for_comments(id)
        #todo the :select doesn't work
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => {:comments => :user},
            :select => ("vote_topics.id, comments.body, users.username, users.votes_count, users.image_file_size, users.image_file_name, users.image_content_type"))
    end

    def self.find_selected_response id
        VoteItem.find(id, :include => [:vote_topic],:select => "vote_topics.header, vote_topics.id, vote_topics.total_votes, vote_items.id, vote_items.option,
                 ag_1_v, ag_2_v, ag_3_v, ag_4_v, male_votes, female_votes")
    end

    def self.get_most_tracked_votes limit, page
        h = Hash.new
        if limit
            coll = find(:all, :conditions => ['status = ?', 'a'], :order => 'vote_topics.total_votes DESC', :include => [{:vote_items => :votes}, :poster, :category, 
                    :trackings], :limit => Constants::SMART_COL_LIMIT, :select => ' vote_topics.id, vote_topics.header, vote_topic.topic, vote_topics.user_id,
                    vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id, users.username,
                    vote_items.option, trackings.count')
        else
            coll = paginate( :conditions => ['status = ?', 'a'], :order => 'vote_topics.total_votes DESC', :include => [{:vote_items => :votes}, :poster, :category,
                    :trackings], :per_page => Constants::LISTINGS_PER_PAGE, :page => page, :select => ' vote_topics.id, vote_topics.header, vote_topic.topic,
             vote_topics.user_id, vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id,
            users.username,vote_items.option')
        end

        sort_collection_vote_items coll
    end
    
    def self.get_tracked_votes id, limit, page
        if limit
            coll = trackings_user_id_equals(id).all(:include => [{:vote_items => :votes}, :poster, :trackings, :category], :limit => Constants::SMART_COL_LIMIT)
        else
            coll = trackings_user_id_equals(id).paginate(:per_page => Constants::LISTINGS_PER_PAGE, :page => page, :include => [{:vote_items => :votes}, :poster,
                    :trackings, :category])
        end
        
        sort_collection_vote_items coll
    end
    
    def self.get_local_votes origin, limit, page
        h = Hash.new
        if limit
            coll = find(:all, :conditions => ['status = ?', 'a'], :order => 'vote_topics.total_votes DESC', :include => [{:vote_items => :votes}, :poster, :category], 
                :limit => Constants::SMART_COL_LIMIT, :select => 'vote_topics.id, vote_topics.header, vote_topic.topic, vote_topics.user_id, vote_topics.category_id,
                vote_topics.created_at, vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id, users.username,
                vote_items.option', :origin => origin, :within => Constants::PROXIMITY)
        else
            coll = paginate(:conditions => ['status = ?', 'a'], :order => 'vote_topics.total_votes DESC', :include => [{:vote_items => :votes}, :poster, :category],
                :select => 'vote_topics.id, vote_topics.header, vote_topic.topic, vote_topics.user_id, vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes,
                categories.id, categories.name, vote_topics.anon, users.id, users.username,vote_items.option', :origin => origin, :within => Constants::PROXIMITY,
                :page => page, :per_page => Constants::LISTINGS_PER_PAGE)
        end
        sort_collection_vote_items coll
    end

    def self.find_for_show(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [{:vote_items => :votes}, :poster, :category, :comments],
            :select => 'vote_topics.status, vote_topics.id, vote_topics.header, vote_topic.topic, vote_topics.user_id, vote_topics.category_id, vote_topics.created_at, 
            vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id, users.username,vote_items.option, total_votes, comments.id,
            comments.body, comments.user_id, comments.vote_topic_id ')
    end
    
    def self.find_for_stats(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [{:vote_items => :votes}], :select => ("vote_topics.id,
        vote_topics.total_votes, vote_items.id, vote_items.option, vote_items.male_votes, vote_items.female_votes, vote_items.ag_1_v,vote_items.ag_2_v,vote_items.ag_3_v
                vote_items.ag_4_v,"))
    end

    def self.find_for_graphs(id)
        find(id, :include => [{:vote_items => :votes}])
    end
    
    
    def self.get_top_votes limit, page
        h = Hash.new
        if limit
            coll = find(:all, :conditions => ['status = ?', 'a'], :order => 'vote_topics.total_votes DESC', :include => [{:vote_items => :votes}, :poster, :category],
                :limit => Constants::SMART_COL_LIMIT, :select => ' vote_topics.id, vote_topics.header, vote_topic.topic, vote_topics.user_id, vote_topics.category_id,
                vote_topics.created_at, vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id, users.username, vote_items.option')
        else
            coll = paginate(:conditions => ['status = ?', 'a'], :order => 'vote_topics.total_votes DESC', :include => [{:vote_items => :votes}, :poster, :category],
                :per_page => Constants::LISTINGS_PER_PAGE, :page => page,:select => ' vote_topics.id, vote_topics.header, vote_topic.topic, vote_topics.user_id,
                vote_topics.category_id, vote_topics.created_at, vote_topics.total_votes, categories.id, categories.name, vote_topics.anon, users.id, users.username,
                vote_items.option')
        end
        sort_collection_vote_items coll
    end

    def self.get_all_votes_user (user)
        coll = user_id_equals(user.id).descend_by_total_votes.all(:include => [{:vote_items => :votes},
                :poster, :category])
        sort_collection_vote_items coll
    end

    def self.sort_collection_vote_items coll
        h = Hash.new
        coll.each do |vt|
            arr = Array.new
            vt.vote_items.sort_by{|vi| vi.votes.size}.reverse_each do |vi|
                arr << vi
            end
            h[vt] = arr
        end
        return h
    end
    
    def get_sorted_vi
        arr = Array.new
        self.vote_items.sort_by {|vi| vi.votes.size}.reverse_each do |vi|
            arr << vi
        end
        return arr
    end

    def send_friendly_emails
        self.delay.deliver_friendly_vote_emails!
    end

    def valid_email?
        if !self.friend_emails.nil?
            emails = self.friend_emails.split(",")
            emails.each do |email|
                if Authlogic::Regex.email.match(email.strip).nil?
                    errors.add(:friend_emails, "Invalid email address")
                    return false
                end
            end
        end
    end

    define_index do
        indexes :header
        indexes :topic
        indexes :status
        indexes vote_items.option, :as => :option
        indexes category.name, :as => :category_name
        
        has created_at, updated_at, :total_votes
        has category_id, user_id, :status
    end

    def destroy_graphs
        path = File.join(Constants::GRAPHS_PATH, "#{self.id}")
        if File.exists?(path)
            FileUtils.rmdir path
        end
    rescue
        #Rescue code here
    end

    def deliver_new_vote_notification!
        Notifier.deliver_new_vote_notification(self)
    end
    
    def deliver_friendly_vote_emails!
        Notifier.deliver_friendly_vote_emails(self)
    end

    def reset
        self.votes.each do |vi|
            vi.destroy
        end
        self.vote_items.each do |v|
            v.reset_counters
        end
        self.update_attribute(:total_votes, 0)
    end
    
    def post_process(selected_response, user, add)
        if add == true
            inc = 1
            user.award_points(Constants::VOTE_POINTS)
        else
            inc = -1
            user.award_points(Constants::VOTE_POINTS * -1)
        end

        if !user.sex.nil? && user.sex == 0
            selected_response.increment!(:male_votes, inc)
        else
            selected_response.increment!(:female_votes, inc)
        end
        age = user.age
        if Constants::AGE_GROUP_1.include?(age)
            selected_response.increment!(:ag_1_v, inc)
        elsif Constants::AGE_GROUP_2.include?(age)
            selected_response.increment!(:ag_2_v, inc)
        elsif Constants::AGE_GROUP_3.include?(age)
            selected_response.increment!(:ag_3_v, inc)
        else
            selected_response.increment!(:ag_4_v, inc)
        end
        #add lat/lng to the vote
        if add == true
            update_location selected_response, user
        end
        vt = vote_items_id_equals(selected_response.id).first(:include => :vote_items)
        vt.update_facets(vt)
        determine_devided
        user.update_attribute(:processing_vote, false)
        
    end

    def update_location selected_response, user
        vote = Vote.voteable_id_equals(selected_response.id).voter_id_equals(user.id)
#        v.lat = user.lat
#        v.lng = user.lng
        v.city = user.city
        v.state = user.state
        vote.save
    end

    def update_facets
        vi = self.vote_items
        f_desc = vi.sort_by{|x| x.female_votes}.reverse.first.option
        m_desc = vi.sort_by{|x| x.male_votes}.reverse.first.option
        ag1_desc = vi.sort_by{|x| x.ag_1_v}.reverse.first.option
        ag2_desc = vi.sort_by{|x| x.ag_2_v}.reverse.first.option
        ag3_desc = vi.sort_by{|x| x.ag_3_v}.reverse.first.option
        ag4_desc = vi.sort_by{|x| x.ag_4_v}.reverse.first.option
        
        f = VoteFacet.vote_topic_id_equals(self.id)
        if f.nil? || f.blank?
            VoteFacet.create(:vote_topic_id => self.id, :fkey => FACET_KEYS.keys[0], :desc => FACET_KEYS["m"] + " " + m_desc)
            VoteFacet.create(:vote_topic_id => self.id,:fkey => FACET_KEYS.keys[1], :desc => FACET_KEYS["w"] + " " + f_desc)
            VoteFacet.create(:vote_topic_id => self.id,:fkey => FACET_KEYS.keys[2], :desc => FACET_KEYS["ag1"] + " " + ag1_desc)
            VoteFacet.create(:vote_topic_id => self.id,:fkey => FACET_KEYS.keys[3], :desc => FACET_KEYS["ag2"] + " " + ag2_desc)
            VoteFacet.create(:vote_topic_id => self.id,:fkey => FACET_KEYS.keys[4], :desc => FACET_KEYS["ag3"] + " " + ag3_desc)
            VoteFacet.create(:vote_topic_id => self.id,:fkey => FACET_KEYS.keys[5], :desc => FACET_KEYS["ag4"] + " " + ag4_desc)
        else
            VoteFacet.vote_topic_id_equals(self.id).fkey_equals(FACET_KEYS.keys[0]).first.update_attribute(:desc, FACET_KEYS["m"] + " " + m_desc)
            VoteFacet.vote_topic_id_equals(self.id).fkey_equals(FACET_KEYS.keys[1]).first.update_attribute(:desc, FACET_KEYS["w"] + " " + f_desc)
            VoteFacet.vote_topic_id_equals(self.id).fkey_equals(FACET_KEYS.keys[2]).first.update_attribute(:desc, FACET_KEYS["ag1"] + " " + ag1_desc)
            VoteFacet.vote_topic_id_equals(self.id).fkey_equals(FACET_KEYS.keys[3]).first.update_attribute(:desc, FACET_KEYS["ag2"] + " " + ag2_desc)
            VoteFacet.vote_topic_id_equals(self.id).fkey_equals(FACET_KEYS.keys[4]).first.update_attribute(:desc, FACET_KEYS["ag3"] + " " + ag3_desc)
            VoteFacet.vote_topic_id_equals(self.id).fkey_equals(FACET_KEYS.keys[5]).first.update_attribute(:desc, FACET_KEYS["ag4"] + " " + ag4_desc)
        end
    end
    
    def determine_devided
        vis = self.vote_items
        vis.each do |v|
            if (v.get_vote_percent_num self.total_votes) > Constants::UNAN_LIMIT
                self.update_attribute(:unan, true)
                return false
            end
        end
        return true
    rescue
        
    end

    
    def make_flash_gender_graph_stacked
        title = Title.new(Constants::GENDER_GRAPH_TITLE)
        title.set_style(Constants::GRAPH_TITLE_STYLE);
        bar_stack = BarStack.new
        vi = self.vote_items
        labels_arr = Array.new
        totals = Array.new

        vi.each do |vv|
            tv = vv.votes.size
            totals << tv
            male_val =  vv.male_votes
            female_val =  vv.female_votes
            
            bar_male = BarStackValue.new(male_val, Constants::GRAPH_MALE_COLOR)
            bar_female = BarStackValue.new(female_val, Constants::GRAPH_FEMALE_COLOR)

            bar_stack.append_stack(Array.new([bar_male, bar_female]))
            labels_arr << XAxisLabel.new(truncate(vv.option, :length => Constants::GRAPH_X_AXIS_LABEL_LENGTH, :omission => '~'),Constants::GRAPH_X_AXIS_LABEL_COLOR,
                Constants::GRAPH_X_AXIS_LABEL_FONT_SIZE, Constants::GRAPH_X_AXIS_LABEL_ANGLE)
        end
        #Make keys
        keys_arr = Array.new
        keys_arr << BarStackKey.new(Constants::GRAPH_MALE_COLOR, "Men", Constants::GRAPH_KEY_SIZE)
        keys_arr << BarStackKey.new(Constants::GRAPH_FEMALE_COLOR, "Women", Constants::GRAPH_KEY_SIZE)
        bar_stack.set_keys(keys_arr)
        
        #        bar_stack.set_tooltip('X label [#x_label#], Value [#val#]<br>Total [#total#]' )
        bar_stack.set_tooltip('#val# of #total#')
        
        y = YAxis.new();
        n = (totals.sort{|x, z| z <=> x})[0]
        y.set_range( 0, n, (n / 5).ceil);
        x = XAxis.new();

        x.labels = labels_arr
        
        x.set_colour(Constants::GRAPH_AXIS_COLOR)
        x.set_grid_colour(Constants::GRAPH_GRID_COLOR)
        y.set_colour(Constants::GRAPH_AXIS_COLOR)
        y.set_grid_colour(Constants::GRAPH_GRID_COLOR)

        x.set_labels_from_array(labels_arr);

        tooltip = Tooltip.new;
        tooltip.set_hover();
        chart = OpenFlashChart.new
        chart.bg_colour = Constants::GRAPHS_BG_COLOR
        chart.set_title(title)
        chart.add_element(bar_stack)
        chart.x_axis = x ;
        chart.y_axis = y ;
        chart.set_tooltip( tooltip );
        return chart.to_s
    end

    def make_flash_age_graph_stacked
        title = Title.new Constants::AGE_GRAPH_TITLE
        title.set_style(Constants::GRAPH_TITLE_STYLE);
        bar_stack = BarStack.new
        
        vi = self.vote_items
        labels_arr= Array.new
        totals = Array.new

        vi.each do |vv|
            totals << vv.votes.size
            ag1 =  vv.ag_1_v
            ag2 = vv.ag_2_v
            ag3 = vv.ag_3_v
            ag4 = vv.ag_4_v
            bar_stack.append_stack(Array.new([BarStackValue.new(ag1,Constants::GRAPH_AG1_COLOR),
                        BarStackValue.new(ag2,Constants::GRAPH_AG2_COLOR), BarStackValue.new(ag3, Constants::GRAPH_AG3_COLOR),
                        BarStackValue.new(ag4,Constants::GRAPH_AG4_COLOR)]))
            labels_arr << XAxisLabel.new(truncate(vv.option, :length => Constants::GRAPH_X_AXIS_LABEL_LENGTH, :omission => '~'),
                Constants::GRAPH_X_AXIS_LABEL_COLOR, Constants::GRAPH_X_AXIS_LABEL_FONT_SIZE, Constants::GRAPH_X_AXIS_LABEL_ANGLE)
        end
        #Make keys
        sag1 = "#{Constants::AGE_GROUP_1.first} - #{Constants::AGE_GROUP_1.last}"
        sag2 = "#{Constants::AGE_GROUP_2.first} - #{Constants::AGE_GROUP_2.last}"
        sag3 = "#{Constants::AGE_GROUP_3.first} - #{Constants::AGE_GROUP_3.last}"
        sag4 = "#{Constants::AGE_GROUP_4.first} - #{Constants::AGE_GROUP_4.last}"

        keys_arr = Array.new
        keys_arr << BarStackKey.new(Constants::GRAPH_AG1_COLOR, sag1, Constants::GRAPH_KEY_SIZE)
        keys_arr << BarStackKey.new(Constants::GRAPH_AG2_COLOR, sag2, Constants::GRAPH_KEY_SIZE)
        keys_arr << BarStackKey.new(Constants::GRAPH_AG3_COLOR, sag3, Constants::GRAPH_KEY_SIZE)
        keys_arr << BarStackKey.new(Constants::GRAPH_AG4_COLOR, sag4, Constants::GRAPH_KEY_SIZE)
        bar_stack.set_keys(keys_arr)
        
        #        bar_stack.set_tooltip('X label [#x_label#], Value [#val#]<br>Total [#total#]' )
        bar_stack.set_tooltip('#val# of #total#' )

        y = YAxis.new();
        n = (totals.sort{|x, z| z <=> x})[0]
        y.set_range( 0, n, (n / 5).ceil);
        x = XAxis.new();
        x.labels = labels_arr

        x.set_colour(Constants::GRAPH_AXIS_COLOR)
        x.set_grid_colour(Constants::GRAPH_GRID_COLOR)
        y.set_colour(Constants::GRAPH_AXIS_COLOR)
        y.set_grid_colour(Constants::GRAPH_GRID_COLOR)
        
        tooltip = Tooltip.new;
        tooltip.set_hover();

        chart = OpenFlashChart.new
        chart.bg_colour = Constants::GRAPHS_BG_COLOR
        chart.set_title(title)
        chart.add_element(bar_stack)

        chart.x_axis = x ;
        chart.y_axis = y ;
        chart.set_tooltip( tooltip );
        return chart.to_s
    end

    def make_flash_pie_graph(return_object)
        pie = Pie.new
        pie.start_angle = 35
        pie.animate = true
        
        pie.colours = ["#504F7D", "#68BC52", "#47703C", "#7E271B", "#BC7E5C"]

        total_votes = self.total_votes
        vals = Array.new
        vi = self.vote_items
        
        vals = Array.new
        vi.each do |x|
            vals << PieValue.new(x.votes.size, "#{x.option}")

        end
        pie.values = vals
        pie.tooltip = '#val# of #total#<br>#percent# of 100%'
        chart = OpenFlashChart.new
        chart.bg_colour = "#ffffff"
        chart.add_element(pie)
        chart.x_axis = nil
        if return_object
            return chart
        else
            return chart.to_s
        end
    end

    

    def what_user_voted_for(user)
        vi = self.vote_items
        if !vi.nil?
            vi.each do |v|
                if user.voted_for?(v)
                    return v.option
                end
            end
        end
        return nil
    end

    def what_vi_user_voted_for(user)
        if user.nil?
            return nil
        else
            vi = self.vote_items
            if !vi.nil?
                vi.each do |v|
                    if user.voted_for?(v)
                        return v
                    end
                end
                return nil
            end
        end
    end
    

    def is_vote_complete?(vt, user)
        vote_complete = false
        vt.each do |v|
            if v.voted_by?(user)
                vote_complete = true
                break
            end
        end
        return vote_complete
    end
    
    def min_vote_items
        if self.vote_items.length < 2
            #            errors.add_to_base("Please specify at least two vote options")
            errors.add(:vote_items, "Please specify at least two vote options")
            return false
        end
    end

    def its_new?
        self.new_record?
    end
    
end
