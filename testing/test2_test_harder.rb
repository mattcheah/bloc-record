# TEST 2: TEST HARDER. 

class Array

    def where(query)
        query = split_by_paren(query)
        has_paren = true
        while has_paren
            if query.include?("(") && query.include?(")") 
                latest_paren = nil
                query.each_with_index do |x, i|
                
                    if x == "("
                        latest_paren = i
                    elsif x == ")"
                        end_paren = i+1
                        # paren_section = query.slice!(latest_paren...end_paren).join("")
                        paren_section = query.slice!(latest_paren...end_paren)
                        query.insert(latest_paren, paren_section)
                        # puts "edited query: #{query.to_s}"
                        break;
                    end
                    
                end
            else
                has_paren = false
            end
            
        end
        remove_parens(query)
        puts "query is: #{query.to_s}"
        puts "============================ Starting the hard part: ============================"
        results = filter_by_conditions(query)
        puts "result is: #{results}"
        puts ""
        results
    end
    
    def filter_by_conditions(condition_array, temp_results=[], directive=nil)
        temp_results ||= []
        comparator_array = []
        condition_array.delete(" ")
        puts ""
        puts "condition array is: #{condition_array.to_s}"
       
        condition_array.each_with_index do |x,i|
            if x.is_a?(Array) && comparator_array.length == 3
                puts "x is an array:  #{x.to_s}"
                # execute and drill down
                puts ""
                puts "calling execute where: previous_conditions #{directive} #{comparator_array[0]} #{comparator_array[1]} #{comparator_array[2]}"
                temp_results = execute(comparator_array[0], comparator_array[1], comparator_array[2], nil, temp_results)
                puts "called executed and got back #{temp_results.to_s}"
                puts ""
                
                comparator_array = []
                temp_results = filter_by_conditions(x, temp_results, directive)
                puts "called filter and got back #{temp_results.to_s}"
                
            elsif x.is_a?(Array) 
                puts "x is an array and we're goign to filter it." 
                temp_results = filter_by_conditions(x, temp_results, directive)
                comparator_array = []
                
                puts "called filter and got back #{temp_results.to_s}"
            elsif x.is_a?(String)
                comparator_array.push(x.delete(" "))
                if comparator_array.length == 4
                    puts "calling execute where: previous_conditions #{directive} #{comparator_array[0]} #{comparator_array[1]} #{comparator_array[2]}"
                    temp_results = execute(comparator_array[0], comparator_array[1], comparator_array[2], directive, temp_results)
                    directive = comparator_array[3]
                    comparator_array = []
                    puts "executed on a 4-string comparator and got back #{temp_results.to_s}"
                    puts ""
                end
                
            end
        end
        unless comparator_array == []
            temp_results = execute(comparator_array[0], comparator_array[1], comparator_array[2], directive, temp_results)
        end
        temp_results
    
    end
    
    def execute(a,b,c,d, temp_results)
        
        case b 
        when ">", "<", ">=", "<="
            c = c.to_i
        when "="
            b = "=="
        end
            
        
        case d
        when "OR", nil
            puts "this is an OR or a nil. array:"+self.to_s
            self.each do |record|
                
                
                # puts "checking if A(#{record[a]}) is #{b} than/to #{c}"
                if record[a].send(b, c) || record[a].send(b, c.to_i)
                    # puts "condition is true, adding this record to list."
                    temp_results.push(record)
                end
            end
        when "AND"
            puts "this is an AND. array:"+temp_results.to_s
            temp_results.each do |record|
                # puts "checking if #{record[a]} is #{b} than/to #{c}"
                unless record[a].send(b, c) || record[a].send(b, c.to_i)
                    # puts "condition is not true! removing this record from the list. "
                    temp_results.delete(record)
                end
            end
        when "NOT"
            puts "this is a NOT. array:"+temp_results.to_s
            i = 0
            (temp_results.length-1).times do
                # puts "checking if #{temp_results[i][a]} is #{b} than/to #{c}"
                if temp_results[i][a].send(b, c) || temp_results[i][a].send(b, c.to_i)
                    # puts "condition is true! deleting this record from the list"
                    temp_results.delete_at(i)
                    i-=1
                end
                # puts "done checking record, temp+results is now: #{temp_results}"
                i += 1
            end
        end
        temp_results
    end
    
    def split_by_paren(query)
        query = query.split(/(\(|\))/)
        query.delete("")
        query
    end
    
    def remove_parens(arr)
        arr.delete("(")
        arr.delete(")")
        arr.each_with_index do |x, i|
            if x.is_a?(Array)
                remove_parens(x)
            else
                arr[i] = x.split(/(=|IS|OR|AND|NOT|>=|<=|<|>)/)
                # puts "x is : #{arr[i]}"
            end
        end
        # puts arr.to_s
    end
end


hash1 = {}
hash2 = {}
hash3 = {}
hash4 = {}
hash5 = {}

hash1["id"] = 1
hash2["id"] = 2
hash3["id"] = 3
hash4["id"] = 4
hash5["id"] = 5

hash1["name"] = "Bob"
hash2["name"] = "Jim"
hash3["name"] = "Billy"
hash4["name"] = "Bob"
hash5["name"] = "Thatcher"

hash1["age"] = 37
hash2["age"] = 15
hash3["age"] = 6
hash4["age"] = 76
hash5["age"] = 120

my_array = [hash1, hash2, hash3, hash4, hash5]

# my_array.where("age > 10")
# #expecting 1, 2, 4, 5

# my_array.where("id = 3")
# #expecting 3

# my_array.where("id = 2 OR age > 50")
# expecting 2, 4, 5

# my_array.where("name = Bob AND age <= 37")
# expecting 1

# my_array.where ("age > 15 NOT name = Bob")
# expecting 5

# my_array.where("name = Bob").where("id = 4")
# expecting 4

 my_array.where("age > 40 OR (name = Bob AND id = 1)")
# expecting: 1, 4, and 5



# break_up("1 = 1 OR (1 = 2 AND 1=3 OR 5 = 5) AND ((12 = 12 OR 1 = 2) OR (5 = 9 AND 1 = 0))")
# => ["WHERE 1 = 1 OR ", "(", "1 = 2 AND 1=3 OR 5 = 5", ")", " AND ", "(", "", "(", "12 = 12 OR 1 = 2", ")", " OR ", "(", "5 = 9 AND 1 = 0", ")", "", ")"]


#break_up("(1)(2)(3)((4)(5))")