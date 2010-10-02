class Vote < ActiveRecord::Base
    belongs_to :user 
    belongs_to :vote_item, :counter_cache => true
    belongs_to :vote_topic, :counter_cache => true

    validates_uniqueness_of :user_id, :scope => [:vote_topic_id], :message => "You have already voted."

    after_create :increment_vote_cache
    
    acts_as_mappable

    def increment_vote_cache
        CacheUtil.increment("vt_votes_#{self.vote_topic.id}", 1)
        #delete the stat cache too
        Rails.cache.delete("vt_stats_#{self.vote_topic.id}")
    end
    
    def self.user_voted?(user_id, vote_topic_id)
        v = find(:first, :conditions => ['user_id = ? AND vote_topic_id = ?', user_id, vote_topic_id])
        if v
            return v.vote_item_id
        else
            return nil
        end
    end
    
    def self.process_votes
        Rails.logger.info "Vote Processor Sarting"
        begin
            processed_count = 0
            deleted_count  = 0

            find_in_batches(:batch_size => 1000, :conditions => ['never_processed = ?',  true]) do |group|
                group.each do |v|
                    v.post_process 
                    processed_count += 1
                end
                #            GC.start
            end
        rescue Exception => exp
            HoptoadNotifier.notify(
                :error_class => "Batch Vote Update",
                :error_message => exp
            )
            Rails.logger.error "Error occured during batch processing votes"
#            error_hash = Hash.new
#            error_hash[:job_name] = "Batch Vote Update"
#            error_hash[:message] = exp.message
#            error_hash[:backtrace] = exp.backtrace.join("\n")
#            Notifier.delay.deliver_job_error "Batch Vote Update", error_hash
        else
            Rails.logger.info  "Vote Processor processed #{processed_count} votes and deleted #{deleted_count} votes"
        end
    end

    def post_process
        begin
            user = self.user
            selected_response = self.vote_item
            inc = 1

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

                self.process_award(self.vote_topic)

                #change the comment organization
                #                self.organize_comments
                user.increment!(:votes_count, inc)

                self.city = user.city
                self.state = user.state
                self.lat = user.lat
                self.lng = user.lng
                self.never_processed = false
                self.save(false)
                #mark it for destruction
            end
        rescue  Exception => exp
            HoptoadNotifier.notify(
                :error_class => "Vote Update",
                :error_message => exp
            )
#            error_hash = Hash.new
#            error_hash[:job_name] = "Vote Process"
#            error_hash[:vote_id] = self.id
#            error_hash[:message] = exp.message
#            error_hash[:backtrace] = exp.backtrace.join("\n")
#            Notifier.delay.deliver_job_error "Vote Process", error_hash
            Rails.logger.error "Error occured during processing vote with id #{self.id}"
            Rails.logger.error exp.backtrace.join("\n")
        end
    end
    
    def process_award(vt)
        if vt.power_offered && vt.power_offered > 0
            voting_points = (vt.power_offered  / Constants::VOTING_POWER_OFFER_DEVIDER) * Constants::VOTE_POINTS
        else
            voting_points = Constants::VOTE_POINTS
        end
        self.user.award_points(voting_points)
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