class ImageJob < Struct.new(:user_id)
    def perform
        User.find(self.user_id).regenerate_styles!
    end
end