require 'populator'
class JobsCommon
    CATEGORIES = ["Arts","Autos & Motorcyles","Business","Computers","Education","Electronics","Entertainment","Environmentalism","Finance","Food & Dining","Games","Health & Fitness",
    "Hobbies",
    "Home & Garden",
    "Kids",
    "Legal",
    "Life & Society",
    "Pets",
    "Real Estate",
    "Recreation & Sports",
    "Relationship Advice",
    "Religion",
    "Science",
    "Social Sciences",
    "Transportation",
    "Travel & Places"]

    def self.check_job_exists (job_name)
        Delayed::Backend::ActiveRecord::Job.first(:conditions => "handler LIKE '%#{job_name}%'")
    end

    def self.do_votes
        User.all.each do |u|
            VoteTopic.all.each do |v|
                vi = v.vote_items
                l = vi.size
                u.vote_for(vi[rand(l)])
            end
        end
    end
    
    def self.populate_votes
        User.all.each do |u|
            (1..3).each do |x|
                a = Array.new
                v = u.vote_topics.create(:topic => Populator.sentences(1), :header => Populator.sentences(1),:anon => rand(2) == 1 ? "true" : "false", :status => 'a',
                    :category_id => rand(25) + 1, :published_at => Time.now + rand(3).minutes)
                (rand(5) + 1).times do |y|
                    a << {:option => Populator.words(rand(3) + 1), :info => Populator.sentences(1)}
                end
                v.vote_items_attributes = a
                v.save
            end
        end
    end

    def self.populate_categories
        CATEGORIES.each do |x|
            Category.create(:name => x)
        end
    end
end