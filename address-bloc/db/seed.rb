require_relative '../models/address_book'
require_relative '../models/entry'
require 'bloc_record'

database_type = :sqlite3

if database_type == :sqlite3
    
    BlocRecord.connect_to('db/address_bloc.sqlite', :sqlite3)
    
    db ||= SQLite3::Database.new(BlocRecord.database_filename)
    
    db.execute("DROP TABLE address_book;")
    db.execute("DROP TABLE entry")
    
    db.execute <<-SQL
        CREATE TABLE address_book (
            id INTEGER PRIMARY KEY, 
            name VARCHAR(30)
        );
    SQL
    
    db.execute <<-SQL
        CREATE TABLE entry (
            id INTEGER PRIMARY KEY,
            address_book_id INTEGER,
            name VARCHAR(30),
            phone_number VARCHAR(30),
            email VARCHAR(30),
            FOREIGN KEY (address_book_id) REFERENCES address_book(id)
        );
    SQL
elsif database_type == :pg
    BlocRecord.connect_to('address_bloc', :pg)
    
    begin
        db ||= PG::Connection.new(dbname: 'address_bloc')
        # puts "connection is : #{@connection}"
    rescue
        db = PG::Connection.new(dbname: "postgres")
        db.exec("CREATE DATABASE 'address_bloc'")
        db = PG::Connection.new(dbname: 'address_bloc')
        puts "connetion created new database, is: #{db}"
    end
    
    begin
        db.exec("DROP TABLE address_book CASCADE;")
        db.exec("DROP TABLE entry")
    rescue
        puts "tables have not yet been created. creating..."
    end
    
    db.exec <<-SQL
        CREATE TABLE address_book (
            id SERIAL PRIMARY KEY,
            name VARCHAR(30)
        );
    SQL
    
    db.exec <<-SQL
        CREATE TABLE entry (
            id SERIAL PRIMARY KEY,
            address_book_id INTEGER,
            name VARCHAR(30),
            phone_number VARCHAR(30),
            email VARCHAR(30),
            FOREIGN KEY (address_book_id) REFERENCES address_book(id)
        );
    SQL
end

book = AddressBook.create(name: 'A Book Of Addresses')

puts "Address Book Created"
puts "book id: #{book.id}" # returns a PG:Result object

Entry.create(address_book_id: book.id, name: "Foo One", phone_number: '999-999-9999', email: 'foo_one@gmail.com')
puts Entry.create(address_book_id: book.id, name: "Foo One", phone_number: '999-9999999', email: 'foo_one_one@gmail.com')
puts Entry.create(address_book_id: book.id, name: "Foo Two", phone_number: '111-111-1111', email: 'foo_two@gmail.com')
puts Entry.create(address_book_id: book.id, name: "Foo Three", phone_number: '222-222-2222', email: 'foo_three@gmail.com')
puts Entry.create(address_book_id: book.id, name: "John", phone_number: '3', email: 'foo_three@gmail.com')

