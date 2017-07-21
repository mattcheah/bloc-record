require 'pg'
require 'sqlite3'

# db = SQLite3::Database.new "db/address_bloc.sqlite"

# db.execute("DROP TABLE address_book;")
# db.execute("DROP TABLE entry")

# db.execute <<-SQL
#     CREATE TABLE address_book (
#         id INTEGER PRIMARY KEY, 
#         name VARCHAR(30)
#     );
#     SQL

# db.execute <<-SQL
#     CREATE TABLE entry (
#         id INTEGER PRIMARY KEY,
#         address_book_id INTEGER,
#         name VARCHAR(30),
#         phone_number VARCHAR(30),
#         email VARCHAR(30),
#         FOREIGN KEY (address_book_id) REFERENCES address_book(id)
#     );
#     SQL

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