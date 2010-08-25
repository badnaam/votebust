class UserSession < Authlogic::Session::Base
    #    rpx_key ENV['RPX_API_KEY']
    rpx_key ENV['RPX_KEY']
    auto_register true


    private

    # map_rpx_data maps additional fields from the RPX response into the user object
    # override this in your session controller to change the field mapping
    # see https://rpxnow.com/docs#profile_data for the definition of available attributes
    #
    def map_rpx_data
        # map core profile data using authlogic indirect column names
        self.attempted_record.send("#{klass.login_field}=", @rpx_data['profile']['displayName'] ) if attempted_record.send(klass.login_field).blank?
        self.attempted_record.send("#{klass.email_field}=", @rpx_data['profile']['email'] ) if attempted_record.send(klass.email_field).blank?
        #              self.attempted_record.send("#{klass.sex_field}=", @rpx_data['profile']['gender'] ) if attempted_record.send(klass.sex_field).blank?
        #              self.attempted_record.send("#{klass.active_field}=", true ) if attempted_record.send(klass.active_field).blank?

        # map some other columns explicitly
        self.attempted_record.active = true if attempted_record.active.blank?
        self.attempted_record.role_id = Role.find_by_name('user').id  if attempted_record.role_id.blank?
        if attempted_record.sex.blank?
            if @rpx_data['profile']['gender'] == 'male'
                self.attempted_record.sex = 0
            elsif @rpx_data['profile']['gender'] == 'female'
                self.attempted_record.sex = 1
            else
                self.attempted_record.sex = 0
            end
        end
        if attempted_record.image_url.blank?
            self.attempted_record.image_url = @rpx_data['profile']['photo']
        end
        #      self.attempted_record.fullname = @rpx_data['profile']['displayName'] if attempted_record.fullname.blank?

        if rpx_extended_info?
            # map some extended attributes
        end
    end

end