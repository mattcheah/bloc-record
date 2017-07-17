require 'bloc_record/utility'
require 'bloc_record/connection'

require 'pg'
require 'sqlite3'



module Schema

    def table
        BlocRecord::Utility.underscore(name)
    end
    
    def schema
        unless @schema
            @schema = {}
            puts "connection is #{connection.to_s}"
            
            if BlocRecord::database_type == :pg
                table_info = connection.exec <<-SQL
                    select column_name, data_type
                    from INFORMATION_SCHEMA.COLUMNS where table_name = '#{table}';
                SQL
                puts table_info.to_s
                
                
            elsif BlocRecord::database_type == :sqlite3

                connection.table_info(table) do |col|
                    @schema[col["name"]] = col["type"]
                end
                
            end
        end
        @schema
    end
    
    def columns
        schema.keys
    end
    
    def attributes
        columns - ["id"]
    end
    
    def count
        connection.execute(<<-SQL)[0][0]
            SELECT COUNT(*) FROM #{table}
        SQL
    end

end