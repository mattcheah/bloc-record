module BlocRecord

    
    def self.connect_to(filename, database_type=:sqlite3)
        @database_type = database_type
        @database_filename = filename
    end
    
    def self.database_filename
        @database_filename
    end
    
    def self.database_type
        @database_type
    end

    
    # #new with addition of potential pg database - see if this works. 
    # def self.require_database
    #     require database_type.to_s
    # end
    
end