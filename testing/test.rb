 def find(*ids)
    if ids.all? { |i| i.is_a?(Integer) && i > 0}
        if ids.length == 1
            find_one(ids.first)
        else
            puts ids.join(",")
        end
    else
        puts "Error: All arguments must be positive integers."
    end
end

puts "finding: (1,2,3,4,5)"
find(1,2,3,4,5)
puts "finding: (1,2,'red','soap')"
find(1,2,'red', 'soap')
puts "finding: (1,2,{name: 'matt'})"
find(1,2,{name: 'matt'})
find(-2, 5, 1, 0)