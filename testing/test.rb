require 'sqlite3'

module Connection
    def connection
        @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    end
end

module Schema

    def table
        BlocRecord::Utility.underscore(name)
    end
    
    def schema
        unless @schema
            @schema = {}
            connection.table_info(table) do |col|
                @schema[col["name"]] = col["type"]
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
    
    puts "putting schema.columns"
    puts schema

end

