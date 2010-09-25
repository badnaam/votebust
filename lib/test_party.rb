require 'rubygems'
require 'httparty'
class TestParty
    include HTTParty
    base_uri "http://tagthe.net/api/"
    #dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
    #require File.join(dir, 'httparty')
    #require 'pp'

    def self.do_extract
        # You can also use post, put, delete, head, options in the same fashion
        h = Hash.new
        VoteTopic.all.each do |v|
            sleep(1)
            response = self.get("", :format => "json", :query => {:text => v.header, :view => 'json'})
            terms = Crack::JSON.parse(response)['memes'][0]["dimensions"]["topic"]
            if !terms.nil?
                terms.each do |t|
                    count = h[t]
                    if count.nil?
                        count = 0
                    else
                        count += 1
                    end
                    h[t] = count
                end
            else
                puts "nil term for #{v.header}"
            end
        end
        puts h.inspect
    end

    def self.show_terms
        puts Crack::JSON.parse(self.do_extract)['memes'][0]["dimensions"]["topic"]
        #        puts self.do_extract.parsed_response["memes"]["dimensions"]["topic"]
    end

end