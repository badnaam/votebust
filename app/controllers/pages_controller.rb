class PagesController < ApplicationController
    layout "normal_page"
    def faq
    end

    def about
    end

    def terms
    end

    def privacy
    end

    def disclaimer
    end

    def contact_receive
        @c = ContactMessage.create(params[:contact_message])
        v = verify_recaptcha(:model => @c, :message => "Text entered did not match the image!")
        if v
            if @c.save
                saved = true
            else
                flash[:error] = "Could not send message."
            end
        else
#            flash[:error] = "Text entered did not match the image."
        end
        respond_to do |format|
            if saved == true
                flash[:success] = "Message sent. We will review your message and get in touch with you shortly."
                @c.delay.deliver_contact_message!
                format.html {redirect_back_or_default root_url}
            else
                format.html {render :action => :contact}
            end

        end
    end
  
    def contact
        @c = ContactMessage.new
    end

    def voting_power
        respond_to do |format|
            format.js
        end
    end
end
