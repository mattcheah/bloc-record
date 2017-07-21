require_relative 'controllers/menu_controller'
require 'bloc_record'

# BlocRecord.connect_to("db/address_bloc.sqlite")
BlocRecord.connect_to("address_bloc", :pg)

menu = MenuController.new
system "clear"
puts "Welcome to AddressBloc!"
menu.main_menu
