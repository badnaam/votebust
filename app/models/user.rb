class User < ActiveRecord::Base
    MAX_PROFILE_IMAGES = 1
    MAX_PROFILE_IMAGE_SIZE = 1.megabyte
    SEX = {0 => "M", 1 => "F"}

    has_attached_file :image, :styles => {:small => "50x50"},
      :path => ":rails_root/public/assets/images/users/:id/:style.:extension",
      :url => "/assets/images/users/:id/:style.:extension",
      :whiny_thumbnails => true

    acts_as_authentic do |a|
        a.validates_length_of_password_field_options = { :within => 1..8, :on =>:update, :if => :has_no_credential?}
        a.validates_length_of_login_field_options = { :within => 1..8, :on =>:update, :if => :has_no_credential?}
    end

    attr_accessible :username, :email, :password, :password_confirmation, :age, :sex, :image
    has_friendly_id :username, :use_slug => true, :approximate_ascii => true, :max_length => 50

    acts_as_voter
    has_many :vote_topics
    belongs_to :role
    has_many :comments
    
    validates_presence_of :email, :sex, :age

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

end
