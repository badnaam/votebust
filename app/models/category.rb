class Category < ActiveRecord::Base
    has_many :vote_topics

    def self.get_all
        find(:all, :select => "id, name")
    end
end
