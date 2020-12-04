mandatory_fields = Set([:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]);
# optional_fields = Set([:cid]);

# checks whether the passport data is valid
function is_valid(data::Dict{Symbol, Any})
  for field in mandatory_fields
    if !haskey(data, field)
      return false
    end
  end
  return true
end

# run if script is run
if abspath(PROGRAM_FILE) == @__FILE__
  filename = "input"; # file to use as input

  # open file
  open(filename) do file
    passports = []; # list of passport data
    num_valid = 0; # number of valid passports
    data = Dict{Symbol, Any}(); # initialize empty data dictionary
    # loop until file is read
    while !eof(file)
      line = readline(file);
      if isempty(line) # if this is a blank line, separating passports
        data[:valid] = is_valid(data);
        if data[:valid]
          num_valid += 1 # update valid counter
        end
        push!(passports, data); # add to list of passports
        data = Dict{Symbol, Any}();
        continue # move on to next line
      end
      # parse passport data
      for entry in split(line)
        field, value = split(entry, ":");
        data[Symbol(field)] = value;
      end
    end
    # validate last passport
    data[:valid] = is_valid(data);
    if data[:valid]
      num_valid += 1
    end
    push!(passports, data);
    # output results
    println([p[:valid] for p in passports]);
    println("Valid: $(num_valid)")
  end
end