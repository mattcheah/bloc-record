require 'bloc_record/schema'
require 'pg'
require 'sqlite3'

module Persistence
    
    def self.included(base)
        base.extend(ClassMethods)
    end
    
    def save!
        
        unless self.id
            self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
            BlocRecord::Utility.reload_obj(self)
            return true
        end
        
        fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")
        
        self.class.connection.execute <<-SQL
            UPDATE #{self.class.table}
            SET #{fields}
            WHERE id = #{self.id}
        SQL
        
        true
    end
    
    def save
        self.save! rescue false
    end
    
    def update_attribute(attribute, value)
        self.update(self.id, {attribute => value})
    end
    
    def update_attributes(updates)
        self.class.update(self.id, updates)
    end
    
    def delete()
        self.class.destroy(self.id)
    end
    
    def method_missing(m, *args, &block)
    
        if m[0..6] == "update_"
            attribute = m[7..m.length-1]
            update_attribute(attribute, args[0])
        else
            super
        end
    
    end
    
    module ClassMethods
        
        def create(attrs)
            attrs = BlocRecord::Utility.convert_keys(attrs)
            attrs.delete "id"
            vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }
            connection.execute <<-SQL
                INSERT INTO #{table} (#{attributes.join ","})
                VALUES (#{vals.join ","});
            SQL
            
            data = Hash[attributes.zip attrs.values]
            data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
            new(data)
            
        end
        
        def update(ids, updates)
            case updates
            when Hash
                ids.each_with_index do |x, i|
                    updates_hash = updates[i]
                    updates_array = updates_hash.map { |key, value| "#{key} = #{BlocRecord::Utility.sql_strings(value)}" } 

                    connection.execute <<-SQL
                        UPDATE #{table}
                        SET #{updates_array.join(",")}
                        WHERE id = #{x};
                    SQL
                    
                end
           
            when Array
            
                updates = BlocRecord::Utility.convert_keys(updates)
                updates.delete "id"
                
                updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }
                
                if ids.class == Fixnum
                    where_clause = "WHERE id = #{ids};"
                elsif ids.class == Array
                    where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(',')});"
                else
                    where_clause = ""
                end
                
                connection.execute <<-SQL
                    UPDATE #{table}
                    SET #{updates_array * ","}
                    #{where_clause};
                SQL
                # is the * a join?
            end
            true
        end
        
        def update_all(updates)
            update(nil, updates)
        end
        
        def destroy(*id)
            if id.length > 1
                where_clause = "WHERE id IN (#{id.join('m')});"
            else
                where_clause = "WHERE id = #{id.first};" 
            end
            
            connection.execute <<-SQL
                DELETE FROM #{table} #{where_clause}
            SQL
            
            true
        end
        
        def destroy_all(*args)
            
            unless args && !args.first.empty?
                connection.execute("DELETE FROM #{table}")
                return true
            end
            
            if args.length == 1
            
                case args.first
                when Hash
                    conditions_hash = BlocRecord::Utility.convert_keys(args.first)
                    conditions = conditions_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
                when String
                    conditions = args.first
                end
            else
                conditions = args.shift
                conditions.gsub!(/\?/) { |m| args.shift }
                conditions
            end
            
            connection.execute <<-SQL
                DELETE FROM #{table}
                WHERE #{conditions};
            SQL
            
            true
        end
        
    end
end