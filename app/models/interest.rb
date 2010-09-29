class Interest < ActiveRecord::Base
    belongs_to :user
    belongs_to :category

    after_create :refresh_interests_cache
    after_destroy :refresh_interests_cache
    
    def self.users_interests user_id
        Rails.cache.fetch("user_interests_#{user_id}")do
            find(:all, :conditions => ['user_id = ?', user_id]).collect{|x| x.category}
        end
    end

    def refresh_interests_cache
        Rails.cache.delete("user_interests_#{self.user_id}")
    end

    def self.send_interest_updates
        users = all(:select => 'distinct user_id').map {|x| x.user_id}
        vote_topics = Array.new
        vote_topics_local = Array.new
        users.each do |i|
            u = User.find(i)
              u.interests.each do |i|
                  category = i.category_id
                  vts = VoteTopic.daily.category_id_equals(category)
                  vote_topics << vts.first if vts.size > 0
                  vts_local = VoteTopic.city_search u.city, true, nil, 'recent'
                  vote_topics_local = vts_local if vts_local.size > 0
              end
        end
        puts vote_topics.size
        puts vote_topics_local.size
#        Notifier.delay.deliver_interest_update vote_topics, vote_topics_local
    end
end
