class News

    include HTTParty
    base_uri  "http://query.yahooapis.com/v1/public/yql"

    def self.new_york_news
       response =  self.get("", :query => {:q => "select title, abstract, url from search.news where query = '%New York%'",
                :format => "json"

            })
    end

    def self.new_york_news_hash
        puts self.new_york_news
        self.new_york_news.parsed_response["query"]["results"]["result"]
    end

end
