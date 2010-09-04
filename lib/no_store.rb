module ActiveSupport
    module Cache
        class NoStore < Store
            def read_multi(*names)
                return nil
            end

            def increment(key, amount = 1)
                return nil
            end

            def decrement(key, amount = 1)
                return nil
            end

            def read(key, options = nil)
                return nil
            end

            def delete(key, options = nil)
                return nil
            end

            def exist?(key, options = nil)
                return false
            end

            def delete_matched(matcher, options = nil)
                return nil
            end

            def write(key, value, options = nil)
                return nil
            end

            def set(key, value, option=nil)
                return nil
            end

            def get(name, options=nil)
                return nil
            end

            def fetch(key, options=nil)
                return nil
            end
            
#            def read_entry(name, options)
#                return nil
#            end
#
#            def write_entry(name, value, options)
#            end
#
#            def delete_entry(name, options)
#            end
            
        end
    end
end 