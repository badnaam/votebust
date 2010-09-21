class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :vote_topic, :counter_cache => true

    validates_presence_of :body, :vote_topic_id, :user_id
    validates_length_of :body, :within => 1..Constants::MAX_COMMENT_LENGTH

    #    before_save :populate_option

    def self.get_comments vid, vi_id, page
        v = VoteTopic.find(vid, :select => 'vote_topics.id, vote_topics.comments_count')
        Rails.cache.fetch("comments_#{vid}_#{vi_id}_#{v.comments_count}_#{page}") do
            paginate(:conditions => ['vote_topic_id = ? AND vi_id = ?', vid, vi_id], :order => 'created_at DESC', :page => page,
                :per_page => Constants::COMMENTS_AT_A_TIME)
        end
    end
    
    def self.do_comment body, vt_id, vi_id, user_id
        v = create(:body => body, :vote_topic_id => vt_id, :vi_id => vi_id, :user_id => user_id)
        if v && v.valid?
            return v
        else
            return nil
        end
    end
    
    def populate_option
        vi = self.vote_topic.what_vi_user_voted_for(self.user)
        if !vi.nil?
            self.vi_option = vi.option
        else
            self.vi_option = Constants::OTHER_VI
        end
    end

#    #Makes sure the comments are categorized under the option the user voted for. Runs every six hours
#    def self.organize_comments
#        Rails.logger.info "Starting comment organization"
#        begin
#            #find votes that have been processed in the last x many hours, only get the ones that have been processed and not marked for delete
#            comments_processed = 0
#            Vote.find_in_batches(:batch_size => Constants::VOTE_BATCH_SIZE,
#                :conditions => ['never_processed = ? AND del = ? AND updated_at > ?',  false, 0, Constants::VOTE_COMMENT_PROCESSING_INTERVAL.ago]) do |group|
#                group.each do |v|
#                    #find all comments for this user and vote_topic
#                    comments = Comment.vote_topic_id_equals(v.vote_topic_id).user_id_equals(v.user_id)
#                    comments.each do |c|
#                        #if not the correct vi, fix it
#                        if !(c.vi_id == v.vote_item_id)
#                            c.update_attribute(:vi_id, v.vote_item_id)
#                            comments_processed += 1
#                        end
#                    end
#                end
#            end
#        rescue => exp
#            Rails.logger.error "Comment organization failed with error #{exp.message}"
#        else
#            Rails.logger.info "Comment organization succeeded!. Processed #{comments_processed} comments."
#        end
#    end

end
