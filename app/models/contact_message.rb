class ContactMessage < ActiveRecord::Base
    MESSAGE_TYPE = {"Suggestion" => 1, "Issue with Website" => 2,  "Business Inquiry" => 3,  "Other" => 4}
    
    validates_presence_of :name, :email, :subject, :msg_type, :body
    validates_length_of :name, :within => 1..100, :message => "Please keep the name within 100 characters"
    validates_length_of :email, :within => 1..100, :message => "Please keep the email within 100 characters"
    validates_length_of :subject, :within => 1..100, :message => "Please keep the subject within 100 characters"
    validates_length_of :body, :within => 1..500, :message => "Please keep the message body within 500 characters"

    

    def deliver_contact_message!
        Notifier.deliver_contact_message(self)
    end
end
