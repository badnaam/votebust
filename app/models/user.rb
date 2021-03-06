class User < ActiveRecord::Base
    MAX_PROFILE_IMAGES = 1
    MAX_PROFILE_IMAGE_SIZE = 1.megabyte
    SEX = {0 => "M", 1 => "F"}

    has_attached_file :image, :styles => {:small => Constants::USER_PROFILE_IMAGE_SIZE, :large => Constants::USER_PROFILE_IMAGE_SIZE_LARGE},
      :path => ":rails_root/public/assets/images/users/:id/:style.:extension",
      :url => "/assets/images/users/:id/:style.:extension",
      :whiny_thumbnails => true, :default_url => '/images/missing.png'

    acts_as_authentic do |a|
        a.validates_length_of_password_field_options = { :within => 1..15, :on =>:update, :if => :has_no_credential?}
        a.validates_length_of_login_field_options = { :within => 1..15, :on =>:update, :if => :has_no_credential?}
        a.account_merge_enabled true
        # set Authlogic_RPX account mapping mode
        a.account_mapping_mode :internal
        a.disable_perishable_token_maintenance = true
        a.login_field = 'username'
    end

    attr_accessible :username, :email, :password, :password_confirmation, :age, :sex, :image, :zip, :birth_year
    has_friendly_id :username, :use_slug => true, :approximate_ascii => true, :max_length => 50,  :cache_column => 'user_cached_slug'

    #    acts_as_voter
    has_many :posted_vote_topics, :foreign_key => :user_id, :class_name => 'VoteTopic',  :dependent => :destroy
    has_many :trackings, :dependent => :destroy
    has_many :tracked_vote_topics, :class_name => "VoteTopic", :foreign_key => :vote_topic_id, :through => :trackings
    belongs_to :role
    has_many :comments, :dependent => :destroy
    has_many :comment_likes, :dependent => :destroy
    has_many :votes, :dependent => :destroy
    has_many :friend_invite_messages, :dependent => :destroy
    has_many :interests, :dependent => :destroy
    attr_accessor :category_ids
    has_many :categories, :through => :interests
    #    acts_as_mappable :auto_geocode=> {:field=>:zip, :error_message=>'Could not geocode address'}
    acts_as_mappable 
    
    validates_presence_of :email, :message => "Please enter a valid email"
    validates_presence_of :sex, :message => "Please select a gender"
    #    validates_presence_of :age, :message => "Please enter your age"
    validates_presence_of :birth_year, :message => "Please enter your year of birth"
    validates_presence_of :zip, :message => "Can't be blank"
    validates_format_of :zip,
      :with => /^[\d]{5}+$/,
      :message => "Not a valid zip code"
    validates_presence_of :birth_year
    #    validates_format_of :birth_year, :with => \d{4}/, :message => "Not a Valid Year"
    attr_accessor :skip_profile_update

    before_save :check_what_changed

    ################################################ named scopes ##################################################################
    named_scope :send_me_updates, lambda {{:conditions => ['active = ? AND update_yes = ?',  true, true],
             :include => [:slug, :interests]}}

    ################################################### end named scopes ###########################################################
    def self.find_for_vote_processing id
        find(id, :select => "users.id, users.voting_power")
    end

    def get_voting_power
        Rails.cache.fetch("user_vp_#{self.id}") do
            self.voting_power
        end
    end
    
    def self.get_user_voting_power id
        Rails.cache.fetch("user_vp_#{self.id}") do
            User.find(id).voting_power
        end
    end
    
    def award_points points
        self.increment!(:voting_power, points)
        #CacheUtil.increment("user_vp_#{self.id}", points)
        Rails.cache.delete("user_vp_#{self.id}")
    end

    def age
        Time.now.year - self.birth_year
    end
    
    def geocode_address
        if !self.zip.nil?
            geo = Geokit::Geocoders::MultiGeocoder.geocode(self.zip)
            #        errors.add(:zip, "Could not locate that zip code") if !geo.success
            logger.error("Zip Validation Error - Could not locate zip code for user with id - #{self.id}") if !geo.success
            if geo.success
                self.lat, self.lng = geo.lat,geo.lng
                self.city = geo.city.titleize if !geo.city.nil?
                st = GeocodeCache.full_state_name geo.state
                self.state = st.titleize if !st.nil?
                #create the city, state entry
                
            else
                #set it to nil to force the user to complete registration
                self.zip = nil
            end
            begin
                save(false)
                if !self.valid?
                    logger.error "Failed to save user record during geocoding"
                    logger.error self.errors.join("\n")
                end
            rescue => exp
                logger.error "Error saving user after geocoding failed with #{exp.message}"
            end
        end
    end

    def check_what_changed
        arr = self.changed.sort
        if arr == ["last_request_at", "perishable_token"] || arr == ["perishable_token" , "processing_vote"] ||
              arr == ["current_login_at", "last_login_at", "last_request_at", "login_count", "perishable_token"] || arr ==  ["voting_power"] || arr ==  ["votes_count"] ||
              arr == ["p_topics_count"]
            self.skip_profile_update = true
            return true
        else
            self.skip_profile_update = false
            return true
        end
    end
    
    named_scope :top_voters, lambda {{:conditions => {:active => true}, :order => 'voting_power DESC', :limit => Constants::SMART_COL_USER_LIMIT,
            :include => [:slug]}}

    def self.get_top_voters
        Rails.cache.fetch("top_voters", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            top_voters
        end
    end

    def self.cities
        Rails.cache.fetch("cities", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            User.all(:select => 'distinct city', :conditions => ['city <> ? and p_topics_count > ?',"", 0]).collect {|x| x.city}
        end
    end
    
    before_image_post_process do |user|
        if user.image_changed?
            user.processing = true
            false # halts processing
        end
    end

    after_save do |user|
        unless user.skip_profile_update
            #update lat lng position
            if user.zip_changed?
                user.delay.geocode_address
            end
            if user.image_changed?
                logger.debug 'queing user image processing job'
                Delayed::Job.enqueue ImageJob.new(user.id)
            end
        end
    end

    def regenerate_styles!
        self.image.reprocess!
        self.processing = false
        self.save(false)
    end

    def image_changed?
        self.image_file_size_changed? ||
          self.image_file_name_changed? ||
          self.image_content_type_changed? ||
          self.image_updated_at_changed?
    end

    def perform
        self.processing = false # unlock for processing
        self.image.reprocess! # do the processing
        self.save
    end
    
    def has_no_credential?
        self.crypted_password.blank?
    end

    def deliver_hello_world!
        Notifier.deliver_hello_world "asitkmishra@gmail.com"
    end
    
    def deliver_activation_instructions!
        reset_perishable_token!
        Notifier.deliver_activation_instructions(self)
    end

    def deliver_activation_confirmation!
        reset_perishable_token!
        Notifier.deliver_activation_confirmation(self)
    end


    def deliver_password_reset_instructions!
        reset_perishable_token!
        Notifier.deliver_password_reset_instructions(self)
    end

    def activate!
        self.active = true
        save
    end

    def voted_for? vid, vtid
        Vote.exists?(:vote_topic_id => vid, :voteable_id => vtid, :user_id => self.id)
    end

    def role_symbols
        arr = Array.new
        arr << self.role.name.to_sym
        return arr
    end

    def unused_rpx_providers
        (Constants::RPX_PROVIDERS - self.get_rpx_providers.split(",")).join(', ')
    end
    
    def get_rpx_providers
        self.rpx_identifiers.collect {|x| x.provider_name}.join(',')
    end


    def total_votes_collected
        Rails.cache.fetch("user_total_votes_collected_#{self.id}_#{self.p_topics_count}") do
            self.posted_vote_topics.sum(:votes_count)
        end
    end
    def total_trackings_collected
        #todo expire this
        Rails.cache.fetch("user_total_trackings_collected_#{self.id}}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            self.posted_vote_topics.sum(:trackings_count)
        end
    end
    def total_discussions_collected
        Rails.cache.fetch("user_total_discussions_collected_#{self.id}}", :expires_in => Constants::LIMITED_LISTING_CACHE_EXPIRATION) do
            self.posted_vote_topics.sum(:comments_count)
        end
    end

    def self.pt_count_key id
        find(id, :select => "p_topics_count").p_topics_count
    end
    private

    # map_added_rpx_data maps additional fields from the RPX response into the user object during the "add RPX to existing account" process.
    # Override this in your user model to perform field mapping as may be desired
    # See https://rpxnow.com/docs#profile_data for the definition of available attributes
    #
    # "self" at this point is the user model. Map details as appropriate from the rpx_data structure provided.
    #
    def self.migrate_user (from_user, to_user)
        if from_user.nil? || to_user.nil?
            logger.info "Fishy fishy"
        end
        logger.info "Migrating #{from_user.id} to #{to_user.id}"
        if !from_user.voting_power.nil?
            to_user.increment!(:voting_power, from_user.voting_power)
        end
        if !from_user.p_topics_count.nil?
            to_user.increment!(:p_topics_count, from_user.p_topics_count)
        end
        if from_user.votes_count > 0
            to_user.votes << from_user.votes
            to_user.increment!(:votes_count, from_user.votes_count)
        end
        if from_user.trackings_count > 0
            to_user.trackings << from_user.trackings
            to_user.increment!(:trackings_count, from_user.trackings_count)
        end
        if from_user.comments.size > 0
            to_user.comments << from_user.comments
        end
        if from_user.comment_likes > 0
            to_user.comment_likes << from_user.comment_likes
        end
        #        to_user.vote_topics << from_user.vote_topics
        if from_user.posted_vote_topics.size > 0
            to_user.posted_vote_topics << from_user.posted_vote_topics
        end
    end

    def map_added_rpx_data( rpx_data )
        # map some additional fields, e.g. photo_url
        self.image_url = rpx_data['profile']['photo'] if image_url.blank?
        if self.sex.blank?
            if @rpx_data['profile']['gender'] == 'male'
                self.sex = 0
            elsif @rpx_data['profile']['gender'] == 'female'
                self.sex = 1
            else
                self.sex = 0
            end
        end
        #todo -review this
        self.email = rpx_data['profile']['email'] if self.email.blank?
        self.username = rpx_data['profile']['displayName'] if self.username.blank?
        #        self.send("#{klass.email_field}=", @rpx_data['profile']['email'] )
        #        self.send("#{klass.login_field}=", @rpx_data['profile']['displayName'] )
    end


    # before_merge_rpx_data provides a hook for application developers to perform data migration prior to the merging of user accounts.
    # This method is called just before authlogic_rpx merges the user registration for 'from_user' into 'to_user'
    # Authlogic_RPX is responsible for merging registration data.
    #
    # By default, it does not merge any other details (e.g. application data ownership)
    #
    def before_merge_rpx_data( from_user, to_user)
        RAILS_DEFAULT_LOGGER.info "Before Merging RPX_Data: migrate VoteTopics, Votes and comments from #{from_user.username} to #{to_user.username}"
        User.delay(:priority => 1).migrate_user(from_user, to_user)

    end

    # after_merge_rpx_data provides a hook for application developers to perform account clean-up after authlogic_rpx has
    # migrated registration details.
    #
    # By default, does nothing. It could, for example, be used to delete or disable the 'from_user' account
    #

    def self.destroy_user user
        user.destroy
    end
    
    def after_merge_rpx_data( from_user, to_user )
        RAILS_DEFAULT_LOGGER.info "After Merging RPX_Data: destroy #{from_user.inspect}"
        User.delay(:priority => 20).destroy_user(from_user)
    end
end
