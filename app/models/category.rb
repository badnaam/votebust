class Category < ActiveRecord::Base
    has_many :vote_topics

end
