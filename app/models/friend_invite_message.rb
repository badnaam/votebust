class FriendInviteMessage < ActiveRecord::Base
    belongs_to :user
    validates_presence_of  :emails
    #    validates_length_of :message, :within => 1..255, :message => "Please keep the name within 255 characters"
    validates_length_of :emails, :within => 1..1000, :message => "Please keep the email within 1000 characters"

    validate :valid_email?

    def valid_email?
        if !self.emails.nil?
            emails = self.emails.split(",")
            emails.each do |email|
                if Authlogic::Regex.email.match(email.strip).nil?
                    errors.add(:friend_emails, "Invalid email address")
                    return false
                end
            end
        end
    end
    
    def deliver_friend_invite_message! email_type, fim
        logger.info "EMAIL TYPE IS????????????????????????????????????????????????????????????????????????????????????????????? #{email_type.class}"
        if email_type == "vote"
            logger.info "sending vote message"
            Notifier.deliver_vote_share_message fim
        elsif email_type == "profile"
            logger.info "sending profile message"
            Notifier.deliver_profile_share_message fim
        elsif  email_type == "invite"
            logger.info "sending invite message"
            Notifier.deliver_friend_invite_message fim
            
        end
    end
end
