require 'rubygems'
include ActionView::Helpers::TextHelper

class VoteTopic < ActiveRecord::Base
    MAX_VOTE_ITEMS = 5
    STATUS = {'approved' => 'a', 'waiting' => 'w', 'preview' => 'p', 'denied' => 'd'}
    DENIAL = {'spam' => 1, 'offensive' => 2, 'a duplicate' => 3}
    FACET_KEYS = {'m' => "Men vote for <option>", 'w' => "Women vote for <option>",
        'ag1' => "Voters aged between #{Constants::AGE_GROUP_1.first} - #{Constants::AGE_GROUP_1.last} vote for <option>",
        'ag2' => "Voters aged between  #{Constants::AGE_GROUP_2.first} - #{Constants::AGE_GROUP_2.last} vote for <option>",
        'ag3' => "Voters aged between  #{Constants::AGE_GROUP_3.first} - #{Constants::AGE_GROUP_3.last} vote for <option>",
        'ag4' => "Voters aged between  #{Constants::AGE_GROUP_4.first} - #{Constants::AGE_GROUP_4.last} vote for <option>",
        'dag' => "Most people who voted were from <thing> ",
        'wl' => "Voters who vote for <option> are from <states> (<cities>)",
        'll' => "Voters who vote for <option> are from <states> (<cities>)",
        'vl' => "Voters near you vote for <option> ",
    }
    #    belongs_to :user
    belongs_to :poster, :class_name => "User", :foreign_key => :user_id
    has_many :trackings, :dependent => :destroy
    has_many :users, :through => :tracking
    has_one :vote_facet
    belongs_to :category
    has_many :comments
    has_many :vote_items, :dependent => :destroy, :order => "votes_count DESC"
    has_many :votes

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

    #    after_save :post_save_processing
    
    attr_accessible :topic, :header, :vote_items_attributes, :friend_emails,  :header, :category_id, :website, :power_offered
    #    has_friendly_id :header, :use_slug => true, :approximate_ascii => true, :max_length => 50, :cache_column => :cached_slug
    
    scope_procedure :awaiting_approval, lambda {status_equals(STATUS['waiting']).ascend_by_created_at}

    named_scope :latest_votes, lambda {{:conditions => ['status = ? AND created_at > ?',  STATUS['approved'], Constants::SMART_COL_LATEST_LIMIT.ago],
            :select => "vote_topics.id, header, created_at",:order => 'created_at DESC', :limit => Constants::SMART_COL_LIMIT}}

    named_scope :same_user, lambda {|user_id|{:conditions => ['status = ? AND user_id = ?',  STATUS['approved'], user_id],
            :select => "vote_topics.id, header, votes_count",:order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT}}

    named_scope :same_category, lambda {|category_id|{:conditions => ['status = ? AND category_id = ?',  STATUS['approved'], category_id],
            :select => "vote_topics.id, header, votes_count",:order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT}}
    
    named_scope :unanimous_votes, lambda {{:conditions => ['expires > ? AND status = ? AND unan = ?', DateTime.now, STATUS['approved'], true], :select => "vote_topics.id, header,
            votes_count, unan",:order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT}}
    named_scope :exp, lambda {{:conditions => ['expires < ? AND status = ?', DateTime.now, STATUS['approved']], :select => "vote_topics.id",
            :order => 'expires DESC'}}
    named_scope :not_exp, lambda {{:conditions => ['expires > ? AND status = ?', DateTime.now, STATUS['approved']],
            :order => 'expires DESC'}}

    def post_save_processing
        if self.status_changed? && self.status == 'a'
            self.poster.delay.award_points(self.power_offered * -1) if !self.power_offered.nil? &&
              self.power_offered > Constants::VOTING_POWER_OFFER_INCREMENT
            self.poster.delay.award_points(Constants::NEW_VOTE_POINTS)
            if !self.friend_emails.nil?
                self.delay.deliver_friendly_vote_emails!
            end
        end 
    end

    def self.all_vt
        CACHE.fetch "#{VoteTopic.count}" do
            all
        end
    end
    
    def is_being_tracked? id
        self.trackings.find(:first, :conditions => ['user_id = ?', id])
    end
    
    #    def self.unanimous_votes
    #        find(:all, :conditions => ['unan = ? && expires > ?'], :order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT, :select => 'id, header, unan, votes_count')
    #    end

    def self.determine_order order
        case order
        when 'recent'
            'vote_topics.created_at DESC'
        when 'votes'
            'vote_topics.votes_count DESC'
        when 'featured'
            'vote_topics.power_offered DESC'
        else
            'vote_topics.created_at DESC'
        end
    end
    def self.category_list cid, page, order
        coll = paginate(:conditions => ['status = ? AND category_id = ?', 'a', cid], :order => (determine_order order), :include => [:vote_items,
                :poster, :category], :page => page, :per_page => Constants::LISTINGS_PER_PAGE, :select => Constants::VOTE_TOPIC_FIELDS)
    end

    def self.general_list page
        coll = paginate(:conditions => ['status = ?', 'a'], :order => 'vote_topics.created_at DESC', :include => [:vote_items, :poster, :category],
            :page => page, :per_page => Constants::LISTINGS_PER_PAGE, :select => Constants::VOTE_TOPIC_FIELDS)
    end

    def self.find_for_processing(id)
        find(id, :include => [:vote_items],
            :select => ("vote_topic.power_offered, vote_topics.id, vote_items.votes_count, vote_items.id, vote_items.option, vote_topics.votes_count"))
    end
    
    def self.find_for_comments(id)
        #todo the :select doesn't work
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => {:comments => :user},
            :select => ("vote_topics.id, comments.body, users.username, users.votes_count, users.image_file_size, users.image_file_name, users.image_content_type"))
    end

    def self.find_selected_response id
        VoteItem.find(id, :include => [:vote_topic],:select => "vote_topics.header, vote_topics.id, vote_topics.votes_count, vote_items.id, vote_items.option,
                 ag_1_v, ag_2_v, ag_3_v, ag_4_v, male_votes, female_votes, vote_topics.trackings_count")
    end
    
    def self.get_most_tracked_votes limit, page
        h = Hash.new
        if limit
            coll = find(:all, :conditions => ['status = ?', 'a'],  :order => 'trackings_count DESC', :include => [:vote_items, :poster,
                    :category], :limit => Constants::SMART_COL_LIMIT, :select => Constants::VOTE_TOPIC_FIELDS)
        else
            coll = paginate( :conditions => ['status = ?', 'a'], :order => 'trackings_count DESC', :include => [:vote_items , :poster,
                    :category], :per_page => Constants::LISTINGS_PER_PAGE, :page => page, :select => Constants::VOTE_TOPIC_FIELDS)
        end
    end
    
    def self.get_tracked_votes id, limit, page
        if limit
            coll = trackings_user_id_equals(id).all(:include => [:vote_items, :poster, :trackings, :category], :limit => Constants::SMART_COL_LIMIT)
        else
            coll = trackings_user_id_equals(id).paginate(:per_page => Constants::LISTINGS_PER_PAGE, :page => page, :include => [:vote_items , :poster,
                    :trackings, :category])
        end
    end
    
    def self.get_local_votes origin, limit, page
        h = Hash.new
        bounds= Geokit::Bounds.from_point_and_radius(origin, Constants::PROXIMITY)
        if limit
            coll = find(:all, :conditions => ['status = ?', 'a'], :order => 'vote_topics.votes_count DESC', :include => [:vote_items , :poster, :category],
                :limit => Constants::SMART_COL_LIMIT, :select => Constants::VOTE_TOPIC_FIELDS, :bounds => bounds)
        else
            coll = paginate(:conditions => ['status = ?', 'a'], :order => 'vote_topics.votes_count DESC', :include => [:vote_items, :poster, :category],
                :select => Constants::VOTE_TOPIC_FIELDS,  :bounds => bounds,:page => page, :per_page => Constants::LISTINGS_PER_PAGE)
        end
        #sort_collection_vote_items coll
    end

    def self.find_for_tracking(id)
        find(id, :select => "vote_topics.id, users.voting_power, users.persistence_token, users.zip,
                users.image_file_name, users.image_content_type, users.image_updated_at, users.image_file_size, vote_topics.trackings_count", :include => [:poster])
    end

    def self.find_for_approval(id)
        find(id, :include => [:poster],
            :select => Constants::VOTE_TOPIC_FIELDS_APPROVAL)
    end
    
    def self.find_for_show(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [:vote_items, :poster, :category, :comments, :vote_facet],
            :select => Constants::VOTE_TOPIC_FIELDS_SHOW)
    end

    def self.find_for_preview_save(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['preview']], :include => [:vote_items, :poster, :category],
            :select => Constants::VOTE_TOPIC_FIELDS_PREV_SAVE)
    end
    
    def self.find_for_show_preview(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [:vote_items, :poster, :category, :comments, :vote_facet],
            :select => Constants::VOTE_TOPIC_FIELDS_SHOW)
    end

    def self.find_for_stats(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [:vote_items], :select => ("vote_topics.id,
        vote_topics.votes_count, vote_items.id, vote_topics.expires, vote_items.option, vote_topics.trackings_count" ))
    end

    def self.find_for_facet_update id
        find(id, :include => [:vote_items, :poster, :votes], :select => "vote_topics.id, vote_topics.votes_count, votes.lat, votes.lng, votes.state,
        votes.city, votes.vote_item_id, vote_items.votes_count, vote_items.male_votes, vote_items.female_votes, vote_items.ag_1_v, vote_items.ag_2_v, vote_items.ag_3_v,
        vote_items.ag_4_v, users.zip, users.id, vote_items.option")
    end

    #todo : fix the expires timestamp issue
    def self.get_featured_votes limit, page
        h = Hash.new
        if limit
            coll = find(:all,:conditions => ['status = ? AND expires > UTC_TIMESTAMP() AND power_offered > 0', 'a'], :order => 'vote_topics.power_offered DESC',
                :include => [:vote_items, :poster, :category],:limit => Constants::SMART_COL_LIMIT, :select => Constants::VOTE_TOPIC_FIELDS)
        else
            coll = paginate(:conditions => ['status = ? AND expires > UTC_TIMESTAMP() AND power_offered > 0', 'a'], :select => Constants::VOTE_TOPIC_FIELDS,
                :order => 'vote_topics.power_offered DESC', :include => [:vote_items, :poster, :category], :per_page => Constants::LISTINGS_PER_PAGE,
                :page => page)
        end
    end

    def self.get_current_time
        lambda {DateTime.now}
    end
    
    def self.get_featured_votes_2 limit, page
        h = Hash.new
        if limit
            coll = find(:all,:conditions => ['status = ? AND expires > ? AND power_offered > 0', 'a', get_current_time.call], :order => 'vote_topics.power_offered DESC',
                :include => [:vote_items ,:poster, :category],:limit => Constants::SMART_COL_LIMIT, :select => Constants::VOTE_TOPIC_FIELDS)
        else
            coll = paginate(:all, :conditions => ['status = ? AND expires > ? AND power_offered > 0', 'a', get_current_time.call], :select => Constants::VOTE_TOPIC_FIELDS,
                :order => 'vote_topics.power_offered DESC', :include => [:vote_items, :poster, :category], :per_page => Constants::LISTINGS_PER_PAGE,
                :page => page)
        end
    end

    def self.get_top_votes limit, page
        h = Hash.new
        if limit
            coll = find(:all, :conditions => ['status = ? AND expires > ? ', 'a', DateTime.now], :order => 'vote_topics.votes_count DESC', :include => [:vote_items,
                    :poster, :category],:limit => Constants::SMART_COL_LIMIT, :select => Constants::VOTE_TOPIC_FIELDS)
        else
            coll = paginate(:conditions => ['status = ? AND expires > ?', 'a', DateTime.now], :order => 'vote_topics.votes_count DESC', :include => [:vote_items,
                    :poster, :category], :per_page => Constants::LISTINGS_PER_PAGE, :page => page,:select => Constants::VOTE_TOPIC_FIELDS)
        end
    end

    def self.get_all_votes_user (id, page)
        coll = paginate(:conditions => ['user_id = ?', id], :order => 'vote_topics.created_at DESC', :include => [:vote_items, :poster, :category],
            :per_page => Constants::LISTINGS_PER_PAGE, :page => page,:select => Constants::VOTE_TOPIC_FIELDS)
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
        indexes poster.city, :as => :city
        indexes poster.state, :as => :state
        
        has created_at, updated_at, :votes_count
        has category_id, user_id, :status

    end

    
    def deliver_new_vote_notification!
        Notifier.deliver_new_vote_notification(self)
    end

    def deliver_denied_vote_notification!(reason)
        Notifier.deliver_denied_vote_notification(self, reason)
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
        self.update_attribute(:votes_count, 0)
    end

    
    def update_facets (print_only)
        if self.votes_count == 0
            if !self.vote_facet.nil?
                self.vote_facet.destroy
            end
            return
        end

        vi = self.vote_items
        winner = vi.first
        looser = vi.last
        
        votes = Array.new
        sorted_votes = self.votes.find(:all, :select => "votes.id, votes.state", :conditions => ['del <> ?', 1]).group_by {|x| x.state}.sort {|a, b| a.size <=> b.size}

        dag_desc = sorted_votes.collect {|x| x.first}.join(', ')

        

        w_desc = vi.sort_by{|x| x.female_votes}.reverse.first.option
        m_desc = vi.sort_by{|x| x.male_votes}.reverse.first.option
        ag1_desc = vi.sort_by{|x| x.ag_1_v}.reverse.first.option
        ag2_desc = vi.sort_by{|x| x.ag_2_v}.reverse.first.option
        ag3_desc = vi.sort_by{|x| x.ag_3_v}.reverse.first.option
        ag4_desc = vi.sort_by{|x| x.ag_4_v}.reverse.first.option
        
        if winner.votes_count> 0
            w_states =  winner.votes.find(:all, :conditions => ['del <> ?', 1]).group_by {|x|x.state}.sort{|a, b| a.size <=> b.size}.collect {|x|x.first}.join(', ')
            w_cities =   winner.votes.find(:all, :conditions => ['del <> ?', 1]).group_by {|x|x.city}.sort{|a, b| a.size <=> b.size}.collect {|x|x.first}.join(', ')
            wl_desc = winner.option + "$$" + w_states + "$$" + w_cities
        end

        if looser.votes_count > 0
            l_states = looser.votes.find(:all, :conditions => ['del <> ?', 1]).group_by {|x|x.state}.sort{|a, b| a.size <=> b.size}.collect {|x|x.first}.join(', ')
            l_cities = looser.votes.find(:all, :conditions => ['del <> ?', 1]).group_by {|x|x.city}.sort{|a, b| a.size <=> b.size}.collect {|x|x.first}.join(', ')
            ll_desc = looser.option + "$$" + l_states + "$$" + l_cities
        end

        local_votes = self.votes.find(:all,  :conditions => ['del <> ?', 1],:origin => self.poster.zip, :within => Constants::PROXIMITY)
        local_winner = local_votes.group_by {|x| x.vote_item_id }.sort {|a, b| a[1].size <=> b[1].size}.reverse.collect {|x| x.first}[0]
        
        if !local_winner.nil?
            vl_desc = VoteItem.find(local_winner, :select => "vote_items.option").option
        end

        f = VoteFacet.find_by_vote_topic_id(self.id)

        if print_only
            puts m_desc
            puts w_desc
            puts ag1_desc
            puts ag2_desc
            puts ag3_desc
            puts ag4_desc
            puts dag_desc
            puts wl_desc
            puts ll_desc
            puts vl_desc
        else
            if f.nil?
                VoteFacet.create(:m => m_desc, :w => w_desc, :ag1 => ag1_desc, :ag2 => ag2_desc, :ag3 => ag3_desc, :ag4 => ag4_desc, :dag => dag_desc,
                    :wl => wl_desc, :ll => ll_desc, :vl => vl_desc, :vote_topic_id => self.id)
            else
                f.update_attributes(:m => m_desc, :w => w_desc, :ag1 => ag1_desc, :ag2 => ag2_desc, :ag3 => ag3_desc, :ag4 => ag4_desc, :dag => dag_desc,
                    :wl => wl_desc, :ll => ll_desc, :vl => vl_desc)
                f.save
            end
        end
    end

    
    def self.start_facet_update
        not_exp.find_in_batches(:batch_size => Constants::FACET_PROCESSING_BATCH_SIZE) do |batch|
            batch.each do |v|
                find_for_facet_update(v.id).update_facets false
            end
        end
        GC.start
    end
    
    def determine_devided
        vis = self.vote_items
        vis.each do |v|
            if (v.get_vote_percent_num self.votes_count) > Constants::UNAN_LIMIT
                self.update_attribute(:unan, true)
                return false
            end
        end
        return true
    rescue
    end

    def self.what_user_voted_for?(vid, user_id)
        v = Vote.user_id_equals(user_id).vote_topic_id_equals(vid).first
        if v.nil?
            return nil
        else
            return v.vote_item_id
        end
    end
    
    def what_vi_user_voted_for(user)
        v = Vote.user_id_equals(user.id).vote_topic_id_equals(self.id).first
        if v.nil?
            return nil
        else
            VoteItem.find(v.vote_item_id)
        end
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
    
    def award_tracking pos
        self.poster.award_points(Constants::TRACK_POINTS * pos)
    end
end
