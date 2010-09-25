class GeocodeCache < ActiveRecord::Base
    STATES = {"oh"=>"Ohio", "fl"=>"Florida", "ct"=>"Connecticut", "ky"=>"Kentucky", "pa"=>"Pennsylvania", "mi"=>"Michigan", "ok"=>"Oklahoma", "la"=>"Louisiana", "tx"=>"Texas", "nc"=>"North Carolina", "nd"=>"North Dakota", "nv"=>"Nevada", "ne"=>"Nebraska", "az"=>"Arizona", "wa"=>"Washington", "mn"=>"Minnesota", "il"=>"Illinois", "ut"=>"Utah", "ri"=>"Rhode Island", "ny"=>"New York", "mo"=>"Missouri", "wv"=>"West Virginia", "nh"=>"New Hampshire", "in"=>"Indiana", "dc"=>"District Of Columbia", "or"=>"Oregon", "ak"=>"Alaska", "sc"=>"South Carolina", "nj"=>"New Jersey", "al"=>"Alabama", "tn"=>"Tennessee", "sd"=>"South Dakota", "ms"=>"Mississippi", "ma"=>"Massachusetts", "de"=>"Delaware", "wy"=>"Wyoming", "mt"=>"Montana", "ks"=>"Kansas", "co"=>"Colorado", "nm"=>"New Mexico", "ia"=>"Iowa", "hi"=>"Hawaii", "wi"=>"Wisconsin", "md"=>"Maryland", "ga"=>"Georgia", "me"=>"Maine", "va"=>"Virginia", "vt"=>"Vermont", "id"=>"Idaho", "ca"=>"California", "ar"=>"Arkansas"}

    def self.store address, city, state, lat, lng, provider
        #        if !city.nil?
        if !state.nil? && state.length == 2 #it's an abbreviation
            state = STATES[state.downcase] if !STATES[state.downcase].nil?
        else
            state = state.downcase
        end
        GeocodeCache.find_or_create_by_address(:address=> address.downcase, :city => city.downcase, :state => state.downcase, :lat=>lat, :lng=>lng,
            :provider => provider)
        #        else
        #            GeocodeCache.find_or_create_by_address(:address=>address.downcase, :city => nil, :lat=>lat, :lng=>lng)
        #        end
    end

    def self.full_state_name state
        if !state.nil? && state.length == 2 #it's an abbreviation
            state = STATES[state.downcase] if !STATES[state.downcase].nil?
        else
            state
        end
    end
end
