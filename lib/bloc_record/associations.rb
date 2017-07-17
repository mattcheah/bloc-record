require 'sqlite3'
require 'active_support/inflector'

module Associations
    def has_many(association)
        define_method(association) do
            rows = self.class.connection.execute <<-SQL
                SELECT * FROM #{association.to_s.singularize}
                WHERE #{self.class.table}_id = #{self.id}
            SQL
            # rows = records from the association table given (etc. )
            
            class_name = association.to_s.classify.constantize #Entry?
            collection = BlocRecord::Collection.new
            
            rows.each do |row|
                collection << class_name.new(Hash[class_name.columns.zip(row)])
                # Entry.new( Hash of row columns and values)
            end
            
            
            collection
            #collection is just a collection (array) of Entries or Addressbooks, etc. etc. 
        end
    end
    
    def belongs_to(association)
    
        define_method(association) do
            association_name = association.to_s
            
            record = self.class.connection.get_first_row <<-SQL
                SELECT * FROM #{association_name}
                WHERE id = #{self.send(association_name + "_id")};
            SQL
            
            class_name = association_name.classify.constantize
            # collection = BlocRecord::Collection.new
            # Maybe just return a hash instead of collection?
            
            class_name.new(Hash[class_name.columns.zip(record)])
            
        end
    
    end
    
    def has_one(association)
        define_method(association) do 
            
            # if owner has one dog, owner.dog retrieves dog.owner_id 
            
            record = self.class.connection.get_first_row <<-SQL
                SELECT * FROM #{association.to_s}
                WHERE #{association.to_s}_id = #{self.id};
            SQL
            
            class_name = association.to_s.classify.constantize
            class_name.new(Hash[class_name.columns.zip(record)])
        
        end
    end
end

