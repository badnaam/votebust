class Notifier < ActionMailer::Base


    def hello_world(email)
        recipients email
        from APP_CONFIG['site_admin_email']
        subject "Hello"
        sent_on Time.now
        body "Here is the body"
    end

    def local_and_interest_updates vts, l_vts, u
        subject "Daily updates from #{APP_CONFIG['site_name']}"
        from          APP_CONFIG['site_admin_email']
        recipients    u.email
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vts => vts, :l_vts => l_vts, :u => u
    end
    
    def local_updates  l_vts, u
        subject "Daily updates in #{u.city} from #{APP_CONFIG['site_name']}"
        from          APP_CONFIG['site_admin_email']
        recipients    u.email
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :l_vts => l_vts, :u => u
    end

    def interest_updates vts, u
        subject "Daily updates from #{APP_CONFIG['site_name']}"
        from          APP_CONFIG['site_admin_email']
        recipients    u.email
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vts => vts, :u => u
    end

    def friend_invite_message(friend_invitation)
        emails = friend_invitation.emails
        subject "Invitation from #{friend_invitation.user.username} at #{APP_CONFIG['site_name']}"
        from          APP_CONFIG['site_admin_email']
        recipients    APP_CONFIG['site_admin_email']
        bcc           emails
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :friend_invitation => friend_invitation, :site_name => APP_CONFIG['site_name']
    end
    def vote_share_message(friend_invitation)
        emails = friend_invitation.emails
        subject "#{friend_invitation.user.username} at #{APP_CONFIG['site_name']} wants to share vote with you."
        from          APP_CONFIG['site_admin_email']
        recipients    APP_CONFIG['site_admin_email']
        bcc           emails
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :friend_invitation => friend_invitation, :site_name => APP_CONFIG['site_name']
    end

    def profile_share_message(friend_invitation)
        emails = friend_invitation.emails
        subject "#{friend_invitation.user.username} at #{APP_CONFIG['site_name']} is sharing their profile with you."
        from          APP_CONFIG['site_admin_email']
        recipients    APP_CONFIG['site_admin_email']
        bcc           emails
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :friend_invitation => friend_invitation, :site_name => APP_CONFIG['site_name']
    end


    def friendly_vote_emails(vote_topic)
        emails = vote_topic.friend_emails
        subject "Vote invitation from #{vote_topic.poster.username} at #{APP_CONFIG['site_name']}"
        from          APP_CONFIG['site_admin_email']
        recipients    APP_CONFIG['site_admin_email']
        bcc           emails
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vote_topic => vote_topic, :site_name => APP_CONFIG['site_name'], :vote_url => scoped_vote_topic_url(vote_topic.category, vote_topic)
    end
    
    def new_vote_notification(vote_topic)
        subject "#{APP_CONFIG['site_name']} - New Vote Notification"
        from          APP_CONFIG['site_admin_email']
        recipients    APP_CONFIG['site_admin_email']
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vote_topic => vote_topic
    end

    def denied_vote_notification(vote_topic, reason)
        subject "#{APP_CONFIG['site_name']} - Vote Topic not approved"
        from          APP_CONFIG['site_admin_email']
        recipients    vote_topic.poster.email
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vote_topic => vote_topic, :reason => reason, :terms_url => terms_url, :faq_url => faq_url
    end

    def approved_vote_notification(vote_topic)
        subject "#{APP_CONFIG['site_name']} - Vote Topic not approved"
        from          APP_CONFIG['site_admin_email']
        recipients    vote_topic.poster.email
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vote_topic => vote_topic
    end

    def contact_message(cm)
        subject "Contact Message - #{cm.subject} - #{ContactMessage::MESSAGE_TYPE[cm.msg_type]}"
        from APP_CONFIG['site_admin_email']
        recipients APP_CONFIG['personal_email']
        sent_on Time.now
        content_type "multipart/alternative"
        body :cm => cm
    end
    
    def password_reset_instructions(user)
        subject       "#{APP_CONFIG['site_name']} Password Reset Instructions"
        from          APP_CONFIG['site_admin_email']
        recipients    user.email
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
    end

    def activation_instructions(user)
        subject "#{APP_CONFIG['site_name']} Activation"
        from APP_CONFIG['site_admin_email']
        recipients user.email
        sent_on Time.now
        content_type "multipart/alternative"
        body :account_activation_url => register_url(user.perishable_token), :site_name => APP_CONFIG['site_name'], :email => APP_CONFIG['site_admin_email']
    end

    def job_error job_name, err_hash
        subject "Error with #{job_name}"
        from          APP_CONFIG['site_admin_email']
        recipients    APP_CONFIG['site_admin_email']
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :error_hash => err_hash
    end
    
    def activation_confirmation(user)
        subject "#{APP_CONFIG['site_name']} Account Activation Confirmation"
        from APP_CONFIG['site_admin_email']
        recipients user.email
        sent_on Time.now
        content_type "multipart/alternative"
        body :root_url => root_url
    end
end
