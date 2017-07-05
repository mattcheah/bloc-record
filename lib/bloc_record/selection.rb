require 'sqlite3'

module Selection
    
    def find(*ids)
        if ids.all? { |i| i.is_a?(Integer) && i > 0}
            if ids.length == 1
                find_one(ids.first)
            else
                rows = connection.execute <<-SQL
                    SELECT #{columns.join ","} FROM #{table}
                    WHERE id IN (#{ids.join(",")});
                SQL
                
                rows_to_array(rows)
            
            end
        else
            puts "Error: All arguments must be positive integers."
        end
    end
    
    def find_one(id)
        if id.is_a?(Integer) && id > 0
            row = connection.get_first_row <<-SQL
                SELECT #{columns.join ","} FROM #{table}
                WHERE id = #{id};
            SQL
            
            init_object_from_row(row)
        else
            puts "Error: id must be a positive integer."
        end
    end
    
    def find_by(attribute, value)
        if columns.include?(attribute)
        
            row = connection.execute(<<-SQL)
                SELECT #{columns.join ","} FROM #{table}
                WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
            SQL
            
            init_object_from_row(row)
        
        else
            puts "Error: `#{attribute}` is not a column name in this table."
        end
    end
    
    def find_each(start=0, batch_size=nil)
        if start == 0 && batch_size == nil
            rows = all
        else
            rows = connection.execute <<-SQL
                SELECT #{columns.join ","} FROM #{table}
                #{start > 0 ? "WHERE id >= #{start} " : ""}
                #{batch_size != nil ? "LIMIT #{batch_size}" : ""}
            SQL
        
        end
        
        rows_to_array(rows).each do |row|
            yield(row)
        end
        
    end
    
    def find_in_batches(start=0, batch_size=nil)
        if start == 0 && batch_size == nil
            rows = all
        else
            rows = connection.execute <<-SQL
                SELECT #{columns.join ","} FROM #{table}
                #{start > 0 ? "WHERE id >= #{start} " : ""}
                #{batch_size != nil ? "LIMIT #{batch_size}" : ""}
            SQL
        
        end
        yield(rows, batch_size)
    
    end
    
    def take(num=1)
        if num >= 1 && num.is_a?(Integer)
            if num == 1 
                take_one
            else
                rows = connection.execute <<-SQL
                    SELECT #{columns.join ","} FROM #{table}
                    ORDER BY random()
                    LIMIT #{num}
                SQL
                
                rows_to_array(rows)
            end
        else 
            puts "Error: Number of records to retrieve must be a positive integer. (You gave: #{num})"
        end
    end
    
    def take_one
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY random()
            LIMIT 1;
        SQL
        
        init_object_from_row(row)
    end
    
    def first 
        row = connection.execute <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY id ASC
            LIMIT 1
        SQL
        
        init_object_from_row(row)
    end
    
    def last
        row = connection.execute <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY id DESC
            LIMIT 1
        SQL
        
        init_object_from_row(row)
    end
    
    def all
        rows = connection.execute <<-SQL
            SELECT #{columns.join ","} FROM #{table}
        SQL
        
        rows_to_array(rows)
    end
    
    def method_missing(m, *args, &block)
    
        if m[0..7] == "find_by_"
            find_attribute = m[8..m.length-1]
            find_by(find_attribute, args[0])
        else
            puts "There's no method called #{m} here -- please try again."  
        end
    
    end
    
    private
    
    def init_object_from_row(row)
        if row
            data = Hash[columns.zip(row)]
            new(data)
        end
    end
    
    def rows_to_array(rows)
        rows.map {|row| new(Hash[columns.zip(row)]) }
    end
    
end