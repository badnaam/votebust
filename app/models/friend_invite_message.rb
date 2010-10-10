class FriendInviteMessage < ActiveRecord::Base
    belongs_to :user
    validates_presence_of :message, :emails
    validates_length_of :message, :within => 1..255, :message => "Please keep the name within 255 characters"
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
    
    def deliver_friend_invite_message! email_type
        case email_type
        when "vote"
            Notifier.deliver_vote_share_message(self)
        when "profile"
            Notifier.deliver_profile_share_message(self)
        when "invite"
            Notifier.deliver_friend_invite_message(self)
        end
        
    end
end
