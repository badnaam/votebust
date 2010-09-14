class Search < ActiveRecord::Base

    def self.location_lat_lng_radian location
        if location.to_i == 0 #it's a city name
            g = GeocodeCache.find(:first, :conditions => ['city = ?', location])
        else
            g = GeocodeCache.find(:first, :conditions => ['address = ?', location])
        end
        return get_radian(g.lat, g.lng)
    end

    def self.get_radian(lat, lng)
        return [(lat / 180.0) * Math::PI, (lng / 180.0) * Math::PI]
    end

    def self.city_search term, city, per_page, page, order
        VoteTopic.search term, :include => [:vote_items, :poster, :category],:geo => location_lat_lng_radian(city),
          :with => {"@geodist" => 0.0..(Constants::PROXIMITY * Constants::METERS_PER_MILE), :status => VoteTopic::STATUS['approved']},
          :latitude_attr => :lat, :longitude_attr => :lng, :per_page => per_page, :page => page, :order => (ModelHelpers.determine_order_search order)
    end

    def self.state_search term, state, per_page, page, order
        VoteTopic.search term, :conditions => {:state => state}, :with => {:status => VoteTopic::STATUS['approved']}, :page => page, :per_page => per_page,
          :include => [:vote_items, :poster, :category], :order => (ModelHelpers.determine_order_search order)
    end

    def self.term_search term, per_page, page, order
        VoteTopic.search term, :page => page, :per_page => per_page, :include => [:vote_items, :poster, :category], 
          :conditions => {:status => VoteTopic::STATUS['approved']}, :order => (ModelHelpers.determine_order_search order)
    end
end
