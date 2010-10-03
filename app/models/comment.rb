class Comment < ActiveRecord::Base
    #    include HoptoadNotifier::Catcher
    belongs_to :user
    belongs_to :vote_topic, :counter_cache => true
    belongs_to :vote_item, :counter_cache => true

    validates_presence_of :body, :vote_topic_id, :user_id
    validates_length_of :body, :within => 1..Constants::MAX_COMMENT_LENGTH

    #    before_create :check_for_spam

    include Rakismet::Model

    named_scope :not_approved, lambda {{:conditions => ['approved =?', false]}}
    named_scope :daily_comments, lambda{{:conditions => ['created_at > ? AND created_at < ?',  Date.today.beginning_of_day, Date.today.end_of_day]}}
    named_scope :hourly_comments, lambda {{:conditions => ['created_at > ?',  Constants::COMMENT_SPAM_CHECK_FREQUENCY.ago]}}
    
    rakismet_attrs :author => proc {user.username},
      :author_email => proc{user.email},
      :content => :body,
      :user_ip => :user_ip,
      :user_agent => :user_agent,
      :referrer => :referrer

    def self.cc_count id
        count(:conditions => ["vote_topic_id = ?", id])
    end
    
    def self.get_comments vid, vi_id, page
        if vi_id.nil?
            ch_key = "comments_#{vid}_others_#{cc_count vid}_#{page}"
        else
            vote_item = VoteItem.find(vi_id)
            ch_key = "comments_#{vid}_#{vi_id}_#{vote_item.comments_count}_#{page}"
        end
        Rails.cache.fetch(ch_key) do
            if vi_id.nil?
                paginate(:conditions => ['vote_topic_id = ? AND vote_item_id IS NULL AND approved = ?', vid, true], :order => 'created_at DESC', :page => page,
                    :per_page => Constants::COMMENTS_AT_A_TIME)
            else
                paginate(:conditions => ['vote_topic_id = ? AND vote_item_id = ? AND approved = ?', vid, vi_id, true], :order => 'created_at DESC', :page => page,
                    :per_page => Constants::COMMENTS_AT_A_TIME)
            end
        end
    end
    
    def self.do_comment body, vt_id, vi_id, user_id, request
        params = {:body => body, :vote_topic_id => vt_id, :vote_item_id => vi_id, :user_id => user_id, :user_ip => request.remote_ip,
            :user_agent => request.env['HTTP_USER_AGENT'],
            :referrer => request.env['HTTP_REFERER']
        }
        v = Comment.create(params)
        #        v = create(:body => body, :vote_topic_id => vt_id, :vi_id => vi_id, :user_id => user_id)
        if v.valid?
            return v
        else
            return nil
        end
    end
    
    def check_for_spam
        begin
            if self.spam? == false
                self.update_attribute(:approved, true)
            else
                self.update_attribute(:approved, false)
            end
        rescue Exception => exp
            HoptoadNotifier.notify(
                :error_class => "Comment Spam Check",
                :error_message => exp
            )
            #            error_hash = Hash.new
            #            error_hash[:job_name] = "Comment Spam Check"
            #            error_hash[:comment_id] = self.id
            get#            error_hash[:message] = exp.message
            #            error_hash[:backtrace] = exp.backtrace.join("\n")
            #            #             HoptoadNotifier.notify()
            #
            #            Notifier.delay.deliver_job_error "Comment Spam Check", error_hash
            logger.error "#{exp.message} occured during checking for spam for comment id #{self.id}"
        ensure
            return true
        end
    end

    def self.spam_check
        begin
            hourly_comments.each do |c|
                c.check_for_spam
            end
        rescue Exception => exp
            #            error_hash = Hash.new
            #            error_hash[:job_name] = "Batch Comment Spam Check"
            #            error_hash[:message] = exp.message
            #            error_hash[:backtrace] = exp.backtrace.join("\n")
            HoptoadNotifier.notify(
                :error_class => "Comment Spam Check Batch",
                :error_message => exp
            )
            #            Notifier.delay.deliver_job_error "Batch Comment Spam Check", error_hash
        else
            Rails.logger.info "Hourly spam check went smoothly."
        end
        
    end

    def self.bad_meth
        begin
            sdfsdf.dfdsfdsf
            
        rescue Exception => exp
            HoptoadNotifier.notify(
                :error_class => "Testing error",
                :error_message => "my message"
            )
            #            notify_about_exception(exp)
        end
    end
end
