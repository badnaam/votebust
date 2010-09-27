class Vote < ActiveRecord::Base
    belongs_to :user 
    belongs_to :vote_item#, :counter_cache => true
    belongs_to :vote_topic#, :counter_cache => true

    validates_uniqueness_of :user_id, :scope => [:vote_topic_id, :never_processed], :message => "You have already voted."

    acts_as_mappable
    
    def self.user_voted?(user_id, vote_topic_id)
        v = find(:first, :conditions => ['user_id = ? AND vote_topic_id = ? AND del = ?', user_id, vote_topic_id, 0])
        if v
            return v.vote_item_id
        else
            return nil
        end
    end

    def self.do_vote vt_id, response, user_id, add
        v = find(:first, :conditions => ['vote_topic_id = ? AND user_id = ? AND del = ?', vt_id, user_id, 0])
        if add == true
            #voting
            if v.nil?
                if create(:user_id => user_id, :vote_item_id => response, :vote_topic_id => vt_id)
                    expire_vote_topic_stats_cache vt_id, response, 1
                    return true
                end
            else
                #there is an existing vote
                if v.never_processed == true
                    #he has a fresh vote
                    return -1
                else
                    #he has a processed vote, check if it's marked for delete, if yes - bg process will take care of rest of the stats
                    # so create a new one
                    if v.del == 1
                        if create(:user_id => user_id, :vote_item_id => response, :vote_topic_id => vt_id)
                            expire_vote_topic_stats_cache vt_id, response, 1
                            return true
                        end
                    end
                end
            end
        else
            #cancelling
            unless v.nil?
                if v.never_processed == true
                    #not a processed vote, safe to destroy, this never existed
                    v.destroy
                    expire_vote_topic_stats_cache vt_id, response, -1
                    return true
                else
                    #mark for deletion, bg processing will take care of stats
                    if v.update_attribute(:del, 1)
                        expire_vote_topic_stats_cache vt_id, response, -1
                        return true
                    else
                        return false
                    end
                end
            end
        end
        return false
    end
    
    def self.expire_vote_topic_stats_cache vt_id, rsp, inc
        VoteTopic.find(vt_id).increment!(:votes_count, inc)
        VoteItem.find(rsp).increment!(:votes_count, inc)
        Rails.cache.delete("vtstat_#{vt_id}")
    end
    
    def self.process_votes
        Rails.logger.info "Vote Processor Sarting"

        processed_count = 0
        deleted_count  = 0

        find_in_batches(:batch_size => 1000, :conditions => ['never_processed = ? OR del = ?',  true, 1]) do |group|
            group.each do |v|
                if v.del == 1
                    v.post_process false
                    if v.del == 2
                        v.destroy
                        deleted_count += 1
                    end
                elsif v.never_processed == true
                    v.post_process true
                    processed_count += 1
                end
            end
            GC.start
        end
        Rails.logger.info  "Vote Processor processed #{processed_count} votes and deleted #{deleted_count} votes"
    end

    def post_process add
        begin
            user = self.user
            selected_response = self.vote_item
            inc = (add == true) ?  1 :  -1

            selected_response.transaction do
                if !user.sex.nil? && user.sex == 0
                    selected_response.increment!(:male_votes, inc)
                else
                    selected_response.increment!(:female_votes, inc)
                end
                age = user.age
                if Constants::AGE_GROUP_1.include?(age)
                    selected_response.increment!(:ag_1_v, inc)
                elsif Constants::AGE_GROUP_2.include?(age)
                    selected_response.increment!(:ag_2_v, inc)
                elsif Constants::AGE_GROUP_3.include?(age)
                    selected_response.increment!(:ag_3_v, inc)
                else
                    selected_response.increment!(:ag_4_v, inc)
                end

                self.process_award(self.vote_topic, add)

                #change the comment organization
                self.organize_comments add

                #                self.vote_topic.increment!(:votes_count, inc)
                #                selected_response.increment!(:votes_count, inc)
                user.increment!(:votes_count, inc)

                if add == true
                    self.city = user.city
                    self.state = user.state
                    self.lat = user.lat
                    self.lng = user.lng
                    self.never_processed = false
                    self.save(false)
                else
                    #mark it for destruction
                    self.update_attribute(:del, 2)
                end
            end
        rescue  => exp
            Rails.logger.error "Error occured during processing vote with id #{self.id}"
            Rails.logger.error DateTime.now.to_s + " - " + exp.message
            Rails.logger.error DateTime.now.to_s + " - " + exp.backtrace.join("\n")
        end
    end


    def organize_comments add
        begin
            vt_id = self.vote_topic_id
            vi_id = self.vote_item_id
            uid = self.user_id
            comments = Comment.vote_topic_id_equals(vt_id).user_id_equals(uid)
            comments.each do |c|
                #if not the correct vi, fix it
                if add
                    #change vi_id for all comment for this vote_topic and this user to vote_item_id of this vote
                    if !(c.vi_id == vi_id)
                        c.update_attribute(:vi_id, vi_id)
                    end
                else
                    #change vi_id for all comments for this vote_topic and this user to nil
                    c.update_attribute(:vi_id, nil)
                end
            end
        rescue => exp
            Rails.logger.error "Error #{exp.message} happened during organizing comment for vote #{self.id} with vote_topic, vote_item, user id as - #{vt_id} - #{vi_id} - #{uid}"
        end
    end
    
    def process_award(vt, add)
        if vt.power_offered && vt.power_offered > 0
            voting_points = (vt.power_offered  / Constants::VOTING_POWER_OFFER_DEVIDER) * Constants::VOTE_POINTS
        else
            voting_points = Constants::VOTE_POINTS
        end
        voting_points = (add == true ? voting_points * 1 : voting_points * -1)
        self.user.increment!(:voting_power, voting_points)
    end
    
    def self.get_voted_vote_topics user_id, limit, page
        user = User.find(user_id, :select => 'users.votes_count, users.id')
        if limit
            Rails.cache.fetch("user_voted_#{user_id}_#{user.votes_count}") do
                find(:all, :conditions => ['votes.user_id = ?', user_id],  :order => 'vote_topics.created_at DESC',
                    :include => [{:vote_topic => [:poster, :category]}], :limit => Constants::SMART_COL_LIMIT)
            end
        else
            Rails.cache.fetch("user_voted_#{user_id}_#{user.votes_count}_#{page}") do
                paginate( :conditions => ['votes.user_id = ?', user_id], :order => 'vote_topics.created_at DESC',
                    :include => [{:vote_topic => [:poster, :category]}], :per_page => Constants::LISTINGS_PER_PAGE,:page => page)
            end
        end
    end
end