class VState < ActiveRecord::Base
    has_many :vote_topics
    validates_uniqueness_of :name
end
