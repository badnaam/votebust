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
        #select users who have preferece set to yes
        #figure out categories for those users
        #figure out vote_topics in that category from the last 1 day
        User.find_in_batches(:batch_size => 100, :conditions => ['active = ? AND (update_yes = ? OR local_update_yes = ?)',  true, true, true]) do |users|
            users.each do |u|
                if u.update_yes == true && u.local_update_yes == true
                    Notifier.deliver_local_and_interest_updates(interest_updates(u), local_interest_updates(u), u)
                elsif u.update_yes == true
                    Notifier.deliver_interest_updates interest_updates(u), u
                elsif u.local_update_yes == true
                    Notifier.deliver_local_updates local_interest_updates(u), u
                end
            end
            GC.start
        end
    end

    def self.interest_updates u
        categories = u.interests
        vts = VoteTopic.category_id_in(categories.map{|x|x.id}).created_at_gte(Date.today.beginning_of_day).descend_by_votes_count.
          all(:limit => 5, :include => [:slug, {:category => :slug}])
        return vts
    end

    def self.local_interest_updates u
        local_vts = VoteTopic.city_search_for_the_day u.zip
        return local_vts
    end
end
