def convert(my_string) 

    my_string.gsub!(/_./) {|x| x[1].upcase }
    
end

puts convert("hello_there_bud")
puts convert("hello_there_bud__HEY")
