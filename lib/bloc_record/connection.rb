

module Connection
    def connection
        case @database_type
        when :pg
            require 'pg'
            @connection ||= PG::Connection.new(:dbname => BlocRecord.database_filename)
            puts "called connection(), @connection is #{@connection.to_s}"
        when :sqlite3
            require 'sqlite3'
            @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
        end
    end
    
    class PG
        def execute(statement)
            exec(statement)
        end
    end
end