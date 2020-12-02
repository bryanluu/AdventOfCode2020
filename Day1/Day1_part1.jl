# run if script is run
if abspath(PROGRAM_FILE) == @__FILE__

input = open("input", "r");

# read entries from input and parse them
entries = parse.(Int, readlines(input));

# sort entries in ascending order
sort!(entries);

# what the sum should be of the two entries
S = 2020;

# start from the lowest entry, check highest entries from the end
found = false;
n = length(entries); # end index
for (i, x) in enumerate(entries)
  if found # if match found, break
    break
  end
  y = S - x; # the correct matching for the given entry
  for j in n:-1:i+1 # loop from the end
    if entries[j] < y
      global n = j; # update end index to the largest possible entry index
      break
    elseif entries[j] == y # the match equals the entry
      global found = true;
      println("x: $(x), y: $(y), x*y: $(x*y)"); # print result and break
      break
    end
  end
end

end