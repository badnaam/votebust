class CacheUtil
    def self.increment(key, amount = 1)
        if (value = Rails.cache.read(key)).nil?
            Rails.cache.write(key, (value = amount))
        else
            Rails.cache.write(key, (value = value + amount))
        end

        return value
    end

    def self.decrement(key, amount = 1)
        if (value = Rails.cache.read(key)).nil?
            value = 0
        else
            Rails.cache.write(key, (value = value - amount))
        end

        return value
    end
end