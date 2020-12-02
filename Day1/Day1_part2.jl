# run if script is run
if abspath(PROGRAM_FILE) == @__FILE__

input = open("input", "r");

# read entries from input and parse them
entries = parse.(Int, readlines(input));

# sort entries in ascending order
sort!(entries);

# what the sum should be of the three entries
S = 2020;
found = false;
# loop through the entries
for (i, x) in enumerate(entries)
  if found
    break
  end
  n = length(entries); # end index
  s = S - x; # remaining sum
  for j in i+1:n # loop through the rest of the entries
    y = entries[j];
    if found || y > s/2 # break if remaining sum can't be reached
      break
    end
    z = s - y; # triplet match amount
    for k in n:-1:j+1 # loop from the end
      if entries[k] < z # if no match found
        n = k;
        break
      elseif entries[k] == z # triplet found
        global found = true;
        # print result and break
        println("x: $(x), y: $(y), z: $(z), x*y*z: $(x*y*z)");
        break
      end
    end
  end
end

end