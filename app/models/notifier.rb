class Notifier < ActionMailer::Base

    ActionMailer::Base.smtp_settings = {
        :address => "smtp.gmail.com",
        :port => 587,
#        :domain => I18n.translate('notifier.domain'),
        :user_name => I18n.translate('notifier.from_email_admin'),
        :password => "badnaam1",
        :authentication => :plain,
        :enable_starttls_auto => true
    }

    def hello_world(email)
        recipients email
        from "pjointadm@gmail.com"
        subject "Hello"
        sent_on Time.now
        body "Here is the body"
    end

    def friendly_vote_emails(vote_topic)
        emails = vote_topic.friend_emails
        logger.debug("Notifier sending friendly_vote_emails to => " + emails)
        
        subject "Vote invitation from #{vote_topic.user.username} at Votebust"
        from          Constants::ADMIN_EMAIL
        recipients    Constants::ADMIN_EMAIL
        bcc           emails
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vote_topic => vote_topic
    end
    
    def new_vote_notification(vote_topic)
        subject "New Vote Notification"
        from          Constants::ADMIN_EMAIL
        recipients    Constants::ADMIN_EMAIL
        sent_on       Time.now
        content_type "multipart/alternative"
        body          :vote_topic => vote_topic
    end

    def password_reset_instructions(user)
        subject       "VoteBust Password Reset Instructions"
        from          "pjointadm@gmail.com"
        recipients    user.email
        sent_on       Time.now
        body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
    end

    def activation_instructions(user)
        subject I18n.translate('notifier.act_sub')
        from I18n.translate('notifier.from_email_admin')
        recipients user.email
        sent_on Time.now
        body :account_activation_url => register_url(user.perishable_token)
    end

    def activation_confirmation(user)
        subject I18n.translate('notifier.act_conf')
        from I18n.translate('notifier.from_email_admin')
        recipients user.email
        sent_on Time.now
        body :root_url => root_url
    end
end
