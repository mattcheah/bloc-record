module BlocRecord
    class Collection < Array
        
        def take #onnnnn meeeeeee
            super
        end
        
        def where(condition_hash = nil)
            return self if condition_hash == nil #for when using where.not()
                
            key = condition_hash.keys.first
            value = condition_hash[key]
            results = Collection.new()
                        
            self.each do |x|
                results.push(x) if x.instance_variable_get("@#{key.to_s}") == value
            end
            results
            
        end
        
        def not(condition_hash)
            key = condition_hash.keys.first
            value = condition_hash[key]
            results = Collection.new()
            
            self.each do |x|
                results.push(x) unless x.instance_variable_get("@#{key.to_s}") == value
            end
            results 
        end
        
        def update_all(updates)
            ids = self.map(&:id)
            
            self.any? ? self.first.class.update(ids, updates) : false
        end
        
        def destroy_all()
            self.each do |x|
                x.delete()
            end
        end
    end
end