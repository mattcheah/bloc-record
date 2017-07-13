module BlocRecord
    class Collection < Array
        
        def take #onnnnn meeeeeee
            super
        end
        
        def where(condition_hash)
            return self if condition_hash == nil #for when using where.not()
            
            key = condition_hash.keys.first
            value = condition_hash[key]
            results = []
            
            self.each do |x|
                results.push(x) if x[key] == value
            end
            
        end
        
        def not(condition_hash)
            key = condition_hash.keys.first
            value = condition_hash[key]
            results = []
            
            self.each do |x|
                results.push(x) unless x[key] == value
            end
        end
        
        def update_all(updates)
            ids = self.map(&:id)
            
            self.any? ? self.first.class.update(ids, updates) : false
        end
    end
end