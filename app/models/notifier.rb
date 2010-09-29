class Notifier < ActionMailer::Base


    def hello_world(email)
        recipients email
        from APP_CONFIG['site_admin_email']
        subject "Hello"
        sent_on Time.now
        body "Here is the body"
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


    def friendly_vote_emails(vote_topic)
        emails = vote_topic.friend_emails
        subject "Vote invitation from #{vote_topic.poster.username} at #{APP_CONFIG['site_name']}"
        from          APP_CONFIG['site_admin_email']
        recipients    APP_CONFIG['site_admin_email']
        bcc           emails
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vote_topic => vote_topic, :site_name => APP_CONFIG['site_name']
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
        body          :vote_topic => vote_topic, :reason => reason, :terms_url => terms_url, :faq_url => faq_url, :site_name => APP_CONFIG['site_name']
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
        body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
    end

    def activation_instructions(user)
        subject "#{APP_CONFIG['site_name']} Activation"
        from APP_CONFIG['site_admin_email']
        recipients user.email
        sent_on Time.now
        body :account_activation_url => register_url(user.perishable_token)
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
        body :root_url => root_url
    end
end
