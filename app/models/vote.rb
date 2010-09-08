class Vote < ActiveRecord::Base
    belongs_to :user 
    belongs_to :vote_item 
    belongs_to :vote_topic

    validates_uniqueness_of :user_id, :scope => [:vote_topic_id, :never_processed], :message => "You have already voted."

    acts_as_mappable

    #if del = 0 not marked for delete, 1 - marked for delete, 2 - processed, go ahead and delete
    
    def self.user_voted?(user_id, vote_topic_id)
        v = find(:first, :conditions => ['user_id = ? AND vote_topic_id = ? AND del <> ?', user_id, vote_topic_id, 1])
        if v
            return v.vote_item_id
        else
            return nil
        end
    end

    def self.do_vote vt_id, response, user_id, add
        v = find(:first, :conditions => ['vote_topic_id = ? AND user_id = ?', vt_id, user_id])
        if add == true
            #voting
            if v.nil?
                create(:user_id => user_id, :vote_item_id => response, :vote_topic_id => vt_id)
                return true
            else
                if v.del == 1
                    create(:user_id => user_id, :vote_item_id => response, :vote_topic_id => vt_id)
                    return true
                else
                    return -1
                end
            end
        else
            #cancelling
            unless v.nil?
                if v.update_attribute(:del, 1)
                    return true
                else
                    return false
                end
            end
        end
        return false
    end
    

    def self.test_log
        begin
            Rails.logger.info "Testing logging"
            a = 4
            a.dsfadsfasdfds
        rescue => exp
            Rails.logger.info "#######################################"
            #            Rails.logger.error DateTime.now.to_s + "- " + exp.backtrace.join("\n")
            Rails.logger.error DateTime.now.to_s + "- " + exp.message
            Rails.logger.info "######################################"
        end
    end

    named_scope :vts, {:conditions => ['votes.id > ? ', 1500], :joins => [:vote_item, :user, :vote_topic],:select => ("votes.id, votes.user_id, users.id, vote_items.id,
        vote_topics.id, users.voting_power, users.sex, users.lat, users.lng, users.zip, users.city,
        users.state, users.age,vote_items.option, vote_topics.power_offered, vote_items.male_votes, vote_items.female_votes, vote_items.ag_1_v, vote_items.ag_2_v,
        vote_items.ag_3_v, vote_items.ag_4_v, vote_items.votes_count, vote_topics.votes_count, users.votes_count, votes.never_processed, votes.del")}

    def self.p_test
        vts.find_in_batches(
            :batch_size => 200, :conditions => ['never_processed = ? OR del = ?',  false, 1]
        ) do |group|
            group.each do |v|
                puts v.user.username
            end
        end
    end

    def self.process_votes
        Rails.logger.info "Vote Processor Sarting"
        #        votes = find(:all, :conditions => ['never_processed = ? OR del = ?',  true, 1], :include => [:vote_item, :user, :vote_topic],
        #            :select => "users.id, vote_items.id, vote_topics.id, users.voting_power, users.sex, users.lat, users.lng, users.zip, users.city, users.state, users.age,
        #        vote_items.option, vote_topics.power_offered, vote_items.male_votes, vote_items.female_votes, vote_items.ag_1_v, vote_items.ag_2_v, vote_items.ag_3_v,
        #        vote_items.ag_4_v, vote_items.votes_count, vote_topics.votes_count, users.votes_count, votes.never_processed, votes.del#")

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

                self.vote_topic.increment!(:votes_count, inc)
                selected_response.increment!(:votes_count, inc)
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
        if limit
            coll = find(:all, :conditions => ['votes.user_id = ?', user_id],  :order => 'vote_topics.trackings_count DESC',
                :include => [{:vote_topic => [:vote_items, :poster, :category]}], :limit => Constants::SMART_COL_LIMIT,
                :select => Constants::VOTE_TOPIC_FIELDS)
        else
            coll = paginate( :conditions => ['votes.user_id = ?', user_id], :order => 'vote_topics.trackings_count DESC',
                :include => [{:vote_topic => [{:vote_items => :votes}, :poster, :category]}], :per_page => Constants::LISTINGS_PER_PAGE,
                :page => page, :select => Constants::VOTE_TOPIC_FIELDS)
        end
    end

end