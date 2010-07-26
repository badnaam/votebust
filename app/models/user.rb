class User < ActiveRecord::Base
    MAX_PROFILE_IMAGES = 1
    MAX_PROFILE_IMAGE_SIZE = 1.megabyte
    SEX = {0 => "M", 1 => "F"}

    has_attached_file :image, :styles => {:small => Constants::USER_PROFILE_IMAGE_SIZE},
      :path => ":rails_root/public/assets/images/users/:id/:style.:extension",
      :url => "/assets/images/users/:id/:style.:extension",
      :whiny_thumbnails => true

    acts_as_authentic do |a|
        a.validates_length_of_password_field_options = { :within => 1..15, :on =>:update, :if => :has_no_credential?}
        a.validates_length_of_login_field_options = { :within => 1..15, :on =>:update, :if => :has_no_credential?}
        a.account_merge_enabled true
        # set Authlogic_RPX account mapping mode
        a.account_mapping_mode :internal
    end

    attr_accessible :username, :email, :password, :password_confirmation, :age, :sex, :image, :zip
    has_friendly_id :username, :use_slug => true, :approximate_ascii => true, :max_length => 50

    acts_as_voter
    has_many :vote_topics
    belongs_to :role
    has_many :comments
    has_many :votes, :foreign_key => :voter_id
    
    validates_presence_of :email, :message => "Please enter a valid email"
    validates_presence_of :sex, :message => "Please select a gender"
    validates_presence_of :age, :message => "Please enter your age"
    validates_presence_of :zip, :message => "Can't be blank"
#    validates_format_of :zip, :with => /^\d{5}(-\d{4})?$/, :message => "should be in the form 12345"
   validates_format_of :zip,
      :with => /^[\d]{5}+$/,
      :message => "Not a valid zip code"


    #    validates_format_of :zip,
    #                    :with => %r{\d{5}(-\d{4})?},
    #                    :message => "Should be 5 digits"
#        validates_format_of :zip, :with => /^[0-9]{5}(-[0-9]{4})?$/, :message => "Invalid Zipcode"
    #    validates_length_of :zip, :is => 5, :message => "Zipcode should be 5 digits"

    scope_procedure :top_voters, lambda {active_equals(true).descend_by_votes_count.all(:limit => Constants::SMART_COL_LIMIT)}
        
    before_image_post_process do |user|
        if user.image_changed?
            user.processing = true
            false # halts processing
        end
    end

    after_save do |user|
        if user.image_changed?
            Delayed::Job.enqueue ImageJob.new(user.id)
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

    def role_symbols
        arr = Array.new
        arr << self.role.name.to_sym
        return arr
    end

    private

    # map_added_rpx_data maps additional fields from the RPX response into the user object during the "add RPX to existing account" process.
    # Override this in your user model to perform field mapping as may be desired
    # See https://rpxnow.com/docs#profile_data for the definition of available attributes
    #
    # "self" at this point is the user model. Map details as appropriate from the rpx_data structure provided.
    #
    def map_added_rpx_data( rpx_data )
        # map some additional fields, e.g. photo_url
        #        self.photo_url = rpx_data['profile']['photo'] if photo_url.blank?
    end

    # before_merge_rpx_data provides a hook for application developers to perform data migration prior to the merging of user accounts.
    # This method is called just before authlogic_rpx merges the user registration for 'from_user' into 'to_user'
    # Authlogic_RPX is responsible for merging registration data.
    #
    # By default, it does not merge any other details (e.g. application data ownership)
    #
    def before_merge_rpx_data( from_user, to_user )
        RAILS_DEFAULT_LOGGER.info "in before_merge_rpx_data: migrate articles and comments from #{from_user.username} to #{to_user.username}"
        to_user.votes << from_user.votes
        to_user.comments << from_user.comments
        to_user.vote_topics << from_user.vote_topics
    end

    # after_merge_rpx_data provides a hook for application developers to perform account clean-up after authlogic_rpx has
    # migrated registration details.
    #
    # By default, does nothing. It could, for example, be used to delete or disable the 'from_user' account
    #
    def after_merge_rpx_data( from_user, to_user )
        RAILS_DEFAULT_LOGGER.info "in after_merge_rpx_data: destroy #{from_user.inspect}"
        from_user.destroy
    end
end
