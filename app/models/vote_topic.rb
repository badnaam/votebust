require 'rubygems'
include ActionView::Helpers::TextHelper

class VoteTopic < ActiveRecord::Base
    include ModelHelpers
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

    ######################associations#########################################
    #    belongs_to :user
    belongs_to :poster, :class_name => "User", :foreign_key => :user_id, :counter_cache => :p_topics_count
    has_many :trackings, :dependent => :destroy
    has_many :users, :through => :tracking
    has_one :vote_facet
    belongs_to :category, :counter_cache => true
    has_many :comments
    has_many :vote_items, :dependent => :destroy, :order => "votes_count DESC"
    has_many :votes

    #############################end associations####################################

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

#    after_save :refresh_caches
    
    #    after_save :post_save_processing
    
    attr_accessible :topic, :anon, :header, :vote_items_attributes, :friend_emails,  :header, :category_id, :website, :power_offered
#    has_friendly_id :header, :use_slug => true, :approximate_ascii => true, :max_length => 50, :cache_column => :cached_slug, :scope => :category
    has_friendly_id :header, :use_slug => true, :approximate_ascii => true, :max_length => 50, :scope => :category

    ############################### named scopes##########################################################################

    ################################################### user for side bars ##############################################
    named_scope :latest_votes, lambda {{:conditions => ['status = ? AND vote_topics.created_at > ?',  STATUS['approved'], Constants::SMART_COL_LATEST_LIMIT.ago],
            :order => 'vote_topics.created_at DESC', :limit => Constants::SMART_COL_LIMIT, :include => [:category]}}

    named_scope :same_user, lambda {|user_id|{:conditions => ['status = ? AND user_id = ?',  STATUS['approved'], user_id],
            :order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT}}
    # todo add expires condition?
    named_scope :top_votes_minimal, lambda {{:conditions => ['status = ?',  STATUS['approved']],
            :order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT, :include => [:category]}}
    
    named_scope :same_category, lambda {|category_id|{:conditions => ['status = ? AND category_id = ?',  STATUS['approved'], category_id],
            :order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT, :include => [:category]}}
    
    named_scope :unanimous_votes, lambda {{:conditions => ['expires > ? AND status = ? AND unan = ?', DateTime.now, STATUS['approved'], true],
            :order => 'votes_count DESC', :limit => Constants::SMART_COL_LIMIT, :include => [:category]}}
    
    named_scope :exp, lambda {{:conditions => ['expires < ? AND status = ?', DateTime.now, STATUS['approved']],
            :order => 'expires DESC'}}
    named_scope :not_exp, lambda {{:conditions => ['expires > ? AND status = ?', DateTime.now, STATUS['approved']],
            :order => 'expires DESC'}}

    ####################################################### user for bg processing ############################################
    scope_procedure :awaiting_approval, lambda {status_equals(STATUS['waiting']).ascend_by_created_at}
    named_scope :daily, lambda{{:conditions => ['created_at > ? AND created_at < ?',  Date.today.beginning_of_day, Date.today.end_of_day]}}
    named_scope :weekly, lambda{{:conditions => ['created_at > ? AND created_at < ?',  Date.today.beginning_of_week, Date.today.end_of_week]}}
    
    named_scope :featured, lambda {{:conditions => ['expires > ? AND status = ? AND power_offered > ?', DateTime.now, STATUS['approved'],
                0]}}
    
    named_scope :most_voted, lambda {{:conditions => ['expires > ? AND status = ? AND votes_count > ?', DateTime.now, STATUS['approved'], 0],
            :order => 'votes_count DESC', :limit => Constants::MOST_VOTED_LIST_SIZE}}
    named_scope :most_tracked, lambda {{:conditions => ['expires > ? AND status = ? AND trackings_count > ? ', DateTime.now, STATUS['approved'], 0],
            :order => 'trackings_count DESC', :limit => Constants::MOST_VOTED_LIST_SIZE}}

    ################################################### others ######################################################
    named_scope :rss, lambda{{:conditions => ['created_at > ?', Constants::RSS_TIME_HORIZON.ago], :order => 'created_at DESC'}}

    ####################################### end named scopes####################################################################

    define_index do
        indexes :header
        indexes :topic
        indexes :status
        indexes vote_items.option, :as => :option
        indexes category.name, :as => :category_name
        indexes poster.city, :as => :city
        indexes poster.state, :as => :state

        has created_at, updated_at, :votes_count, :power_offered, :trackings_count
        has category_id, user_id, :status

        has "RADIANS(users.lat)",  :as => :lat,  :type => :float
        has "RADIANS(users.lng)", :as => :lng, :type => :float
    end

    ######################################### sidebar index finders, # todo, createa  module for this #############################
    def self.get_same_category id
        Rails.cache.fetch("side_bar_same_category_#{id}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            same_category id
        end
    end
    
    def self.get_latest
        Rails.cache.fetch("latest", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            latest_votes
        end
    end
    
    def self.get_unanimous_vote_topics
        Rails.cache.fetch("unanimous", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            unanimous_votes
        end
    end
    #todo removve anonymous
    def self.get_more_from_same_user id
        Rails.cache.fetch("more_from_same_user_#{id}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            same_user id
        end
    end

    def self.get_top_votes_minimal
        Rails.cache.fetch("top_votes_minimal", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            top_votes_minimal
        end
    end

    #################### end sidebar index finders################################################################################

    #################### index finders ###########################################
    def self.category_list cname, page, order
        c = Category.find(cname)
        Rails.cache.fetch("cat_list_#{page}_#{order}_#{c.id}_#{c.vote_topics_count}") do
            paginate(:conditions => ['status = ? AND category_id = ?', 'a', c.id], :order => (ModelHelpers.determine_order order), :include => [:vote_items,
                    :poster, :category], :page => page, :per_page => Constants::LISTINGS_PER_PAGE)
        end
    end

    def self.general_list page, order
        Rails.cache.fetch("all_vote_topics_#{page}_#{order}_#{ca_key}") do
            paginate(:conditions => ['status = ?', 'a'], :order => (ModelHelpers.determine_order order), :include => [:vote_items, :poster, :category],
                :page => page, :per_page => Constants::LISTINGS_PER_PAGE)
        end
    end
    
    def self.get_most_tracked_votes limit, page, order
        if limit
            order = 'vote_topics.trackings_count DESC, ' + (ModelHelpers.determine_order order)
            find(:all, :conditions => ['status = ?', 'a'],  :order => order, :include => [:poster,
                    :category], :limit => Constants::SMART_COL_LIMIT)
        else
            Rails.cache.fetch("most_tracked_all_#{page}_#{order}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
                order = 'vote_topics.trackings_count DESC, ' + (ModelHelpers.determine_order order)
                paginate( :conditions => ['status = ?', 'a'], :order => order, :include => [:vote_items , :poster,
                        :category], :per_page => Constants::LISTINGS_PER_PAGE, :page => page)
            end
        end
    end

    ## tracked by the user
    def self.get_tracked_votes user, limit, page, order
        if limit
            Rails.cache.fetch("trackings_limited_#{user.id}_#{user.trackings_count}") do
                order = 'vote_topics.trackings_count DESC, ' + (ModelHelpers.determine_order order)
                trackings_user_id_equals(user.id).all(:include => [:poster, :category], :limit => Constants::SMART_COL_LIMIT, :order => order)
            end
        else
            Rails.cache.fetch("trackings_all_#{user.id}_#{user.trackings_count}_#{page}_#{order}") do
                order = 'vote_topics.trackings_count DESC, ' + (ModelHelpers.determine_order order)
                trackings_user_id_equals(user.id).paginate(:per_page => Constants::LISTINGS_PER_PAGE, :page => page, :include => [ :poster,
                        :category], :order => order)
            end
        end
    end

    #todo : fix the expires timestamp issue
    def self.get_featured_votes limit, page, order
        if limit
            order = 'vote_topics.power_offered DESC, ' + (ModelHelpers.determine_order order)
            find(:all,:conditions => ['status = ? AND expires > UTC_TIMESTAMP() AND power_offered > 0', 'a'], :order => order,
                :include => [:poster, :category],:limit => Constants::SMART_COL_LIMIT)
        else
            Rails.cache.fetch("featured_all_#{page}_#{order}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
                order = 'vote_topics.power_offered DESC, ' + (ModelHelpers.determine_order order)
                paginate(:conditions => ['status = ? AND expires > UTC_TIMESTAMP() AND power_offered > 0', 'a'],
                    :order => order, :include => [:poster, :category], :per_page => Constants::LISTINGS_PER_PAGE,
                    :page => page)
            end
        end
    end

    def self.get_top_votes limit, page, order
        if limit
            order = 'vote_topics.votes_count DESC, ' + (ModelHelpers.determine_order order)
            coll = find(:all, :conditions => ['status = ? AND expires > ? ', 'a', DateTime.now], :order => order, :include => [:vote_items,
                    :poster, :category],:limit => Constants::SMART_COL_LIMIT, :select => Constants::VOTE_TOPIC_FIELDS)
        else
            coll = Rails.cache.fetch("top_all_#{page}_#{order}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
                order = 'vote_topics.votes_count DESC, ' + (ModelHelpers.determine_order order)
                paginate(:conditions => ['status = ? AND expires > ?', 'a', DateTime.now], :order => order, :include => [:vote_items,
                        :poster, :category], :per_page => Constants::LISTINGS_PER_PAGE, :page => page,:select => Constants::VOTE_TOPIC_FIELDS)
            end
        end
    end

    def self.get_all_votes_user id, page, order
        coll = Rails.cache.fetch("user_all_#{id}_#{page}_#{order}_#{User.find(id).p_topics_count}") do
            order = (ModelHelpers.determine_order order) + ', vote_topics.created_at DESC'
            paginate(:conditions => ['user_id = ?', id], :order => order, :include => [:vote_items, :poster, :category],
                :per_page => Constants::LISTINGS_PER_PAGE, :page => page,:select => Constants::VOTE_TOPIC_FIELDS)
        end
    end

    #################### end index finders#####################################################

    ################ individual finders #########################################################

    def self.find_for_tracking(id)
        find(id, :select => "vote_topics.id, vote_topics.header, users.voting_power, users.persistence_token, users.zip,
                users.image_file_name, users.image_content_type, users.image_updated_at, users.image_file_size, vote_topics.trackings_count", :include => [:poster])
    end

    def self.find_for_approval(id)
        find(id, :include => [:poster]
        )
    end
    
    def self.find_for_show(id, scp)
        Rails.cache.fetch("vt_#{id}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [:vote_items, :poster, :category, :vote_facet], :scope => scp)
        end
    end
    
    def self.find_for_preview_save(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['preview']], :include => [:vote_items, :poster, :category])
    end
    
    def self.find_for_show_preview(id, scope)
        puts "id is #{id}"
        puts "scope is #{scope}"
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [:vote_items, :poster, :category, :vote_facet, :slugs],
            :scope => scope)
    end

    def self.find_for_stats(id)
        find(id, :conditions => ['status = ?', VoteTopic::STATUS['approved']], :include => [:vote_items])
    end

    def self.find_selected_response id
        VoteItem.find(id, :include => [:vote_topic])
    end

    def self.find_for_facet_update id
        find(id, :include => [:vote_items, :poster, :votes])
    end

    ########################### end individual finders######################################################################

    
    
    
    ############################# notifications ####################################
    def deliver_new_vote_notification!
        Notifier.deliver_new_vote_notification(self)
    end

    def deliver_denied_vote_notification!(reason)
        Notifier.deliver_denied_vote_notification(self, reason)
    end
    
    def deliver_friendly_vote_emails!
        Notifier.deliver_friendly_vote_emails(self)
    end

    ################################end notifications######################################

    #############################updates/manipulations###################################
    def is_unan?
        vis = self.vote_items
        vis.each do |v|
            if (v.get_vote_percent_num self.votes_count) > Constants::UNAN_LIMIT
                return true
            end
        end
        return false
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
        begin
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
            sorted_votes = self.votes.find(:all,  :conditions => ['del <> ?', 1]).group_by {|x| x.state}.sort {|a, b| a.size <=> b.size}

            dag_desc = sorted_votes.collect {|x| x.first}.join(', ')

            f_winner = vi.sort_by{|x| x.female_votes}.reverse.first
            if f_winner.female_votes > 0
                w_desc = f_winner.option
            end
            m_winner = vi.sort_by{|x| x.male_votes}.reverse.first
            if m_winner.male_votes > 0
                m_desc = m_winner.option
            end

            ag1_winner = vi.sort_by{|x| x.ag_1_v}.reverse.first
            if ag1_winner.ag_1_v > 0
                ag1_desc = ag1_winner.option
            end
            ag2_winner = vi.sort_by{|x| x.ag_2_v}.reverse.first
            if ag2_winner.ag_2_v > 0
                ag2_desc = ag2_winner.option
            end
            ag3_winner = vi.sort_by{|x| x.ag_3_v}.reverse.first
            if ag3_winner.ag_3_v > 0
                ag3_desc = ag3_winner.option
            end
            ag4_winner = vi.sort_by{|x| x.ag_4_v}.reverse.first
            if ag4_winner.ag_4_v > 0
                ag4_desc = ag4_winner.option
            end

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
            if local_votes.size > 0
                local_winner = local_votes.group_by {|x| x.vote_item_id }.sort {|a, b| a[1].size <=> b[1].size}.reverse.collect {|x| x.first}[0]
            end

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
        rescue => exp
            logger.error "Error during updating facet - #{exp.message}. VoteTopic was #{self.id}"
            logger.error  exp.backtrace.join("\n")
        end
    end


    def process_flag flag_name
        begin
            if self.flags.nil? || self.flags.blank?
                self.update_attribute(:flags, flag_name)
            else
                a = self.flags.split(',')
                if !a.include?(flag_name)
                    a << flag_name
                    self.update_attribute(:flags, a.join(','))
                end
            end
        rescue => exp
            logger.error "Error occurd during processing flags for vote topic #{self.id}. Error is #{exp.message}"
        end
    end
    
    ####################################### end updates/manipulations##########################################################


    ############################ called from rake tasks #################################################################
    def self.start_facet_update
        update_count = 0
        begin
            not_exp.find_in_batches(:batch_size => Constants::FACET_PROCESSING_BATCH_SIZE) do |batch|
                batch.each do |v|
                    find_for_facet_update(v.id).update_facets false
                    update_count += 1
                end
            end
        rescue => exp
            logger.error "Error occured in starting facet update #{exp.message}"
            logger.error exp.backtrace.join("\n")
        else
            logger.info "#{update_count} Facets Update completed successfully!"
        ensure
            #            GC.start
        end
    end

    def self.process_vote_topic_flags
        begin
            featured.daily.each do |v|
                v.process_flag('featured')
            end

            most_voted.daily.each do |v|
                v.process_flag('most_voted')
            end
            most_tracked.daily.each do |v|
                v.process_flag('most_tracked')
            end

            weekly.each do |v|
                if v.is_unan?
                    v.update_attribute(:unan, true)
                end
            end
        rescue => exp
            logger.error "Error occured during process flags #{exp.message}"
        end
    end

    ########################################### end called from rake tasks ######################################

    ###################### Misc helpers #######################################################
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
    
    def is_being_tracked? id
        self.trackings.find(:first, :conditions => ['user_id = ?', id])
    end

    def refresh_caches
        #        Rails.cache.delete('all_vote_topics_listing')
        #check the category and delete the specific category cache
#        if self.status == STATUS['approved']
#            Rails.cache.delete('category_listing')
#        end
    end

    def self.newest
        status_equals(STATUS['approved']).descend_by_created_at.first
    end
    
    def self.ca_key
        newest.nil? ? "0:0" : "#{newest.created_at.to_i}:#{count}"
    end
    
    ########### end misc helpers#######################################################
    
end
