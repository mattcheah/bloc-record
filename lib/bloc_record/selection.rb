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
        
            row = connection.execute <<-SQL
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
        yield(rows_to_array(rows), batch_size)
    
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
    
    def where(*args)
        if args.count > 1
            expression = args.shift
            params = args
        else
            case args.first
            when String
                expression = args.first
            when Hash
                    expression_hash = BlocRecord::Utility.convert_keys(args.first)
                    expression = expression_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
            end
        end
        
        sql = <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            WHERE #{expression};
        SQL
        
        rows = connection.execute(sql, params)
        rows_to_array(rows)
    end
    
    def order(*args)
        order = ""
        
        args.each do |arg|
            
            case arg
            when String || Symbol
                order += arg.to_s
            when Hash
                arg.each_key do |key|
                    order += "#{key} #{args.first[key]} "
                end
            end
            
            order += ", "
            
        end
        
        rows = connection.exectue <<-SQL
            SELECT * FROM #{table}
            ORDER BY #{order}
        SQL
        rows_to_array(rows)
        
    end
    
    def join(*args)
        if args.count > 1
            joins = args.map { |arg| "INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id"}.join(" ")
            rows = connection.execute <<-SQL
                SELECT * FROM #{table} #{joins}
            SQL
            
        else
            case args.first
            when String
                rows = connection.execute <<-SQL
                    SELECT * FROM #{table} #{BlocRecord::Utility.sql_strings(args.first)};
                SQL
            when Symbol
                rows = connection.execute <<-SQL
                    SELECT * FROM #{table}
                    INNER JOIN #{args.first} ON #{args.first}.#{table}_id = #{table}.id
                SQL
            end
        end
        
        rows_to_array(rows)
    end
    
    def joins(arg) # should only have 1 argument which is a hash? 
        
        join_one = arg.keys.first
        join_two = arg[join_one]
        
        rows = connection.execute <<-SQL
            SELECT * FROM #{table}
            INNER JOIN #{join_one} ON #{join_one}.#{table}_id = #{table}_id
            INNER JOIN #{join_two} ON #{join_two}.#{join_one}_id = #{join_one}.id
        SQL
        
        rows_to_array(rows)
        
        # ANSWER TO CHECKPOINT 4 QUESTION
        # SELECT department.department_name, avg(compensation.vacation_days) FROM department
        # JOIN professor ON department.id = professor.department_id
        # JOIN compensation ON professor.id = compensation.professor_id
        # GROUP BY department_name;
    end
    
    private
    
    def init_object_from_row(row)
        if row
            data = Hash[columns.zip(row)]
            new(data)
        end
        # THIS RETURNS AN ARRAY OF EACH ITEM RETURNED, EACH ITEM IN THE ARRAY IS A HASH OF THE VALUES WITH THE COLUMN AS IT'S KEY.
    end
    
    def rows_to_array(rows)
        rows.map {|row| new(Hash[columns.zip(row)]) }
    end
    
    #Lets see how this works: 
    # columns is schema.keys: [id, deparment_name, professor_name]
    #
    
end

class Array
    
    def where(condition)
        case condition
        when String
            condition = condition.split(/(=|IS|OR|AND|NOT|>=|<=|<|>)/)
        end

        result_array = []
        directive = nil
        condition.each_slice(4) do |a, b, c, d|
            
            case directive
            when nil
                self.each do |record|
                    if record[a].send(b, c)
                        result_array.push(record)
                    end
                end
            when "AND"
                result_array.each do |record|
                    unless record[a].send(b, c)
                        result_array.delete(record)
                    end
                end
            when "OR"
                self.each do |record|
                    if record[a].send(b, c) && self.include?(record)==false
                        result_array.push(record)
                    end
                end
            when "NOT"
                result_array.each do |record|
                    if record[a].send(b, c)
                        result_array.delete(record)
                    end
                end
            end
            

            
            directive = d
            
            # case directive
            # when nil
                
            # when "AND"
                
            # when "OR"
    
            # when "NOT"
                
            # end
            
            # AND WHAT ABOUT PARENTHESES AND ORDER OF OPERATIONS? LIFE IS SO HARD. 
            
        end
        
        result_array
        
    end
    

end