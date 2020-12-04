mandatory_fields = Set([:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]);
# optional_fields = Set([:cid]);

# bounds used to validate
bounds = Dict();
bounds[:byr] = (1920, 2002);
bounds[:iyr] = (2010, 2020);
bounds[:eyr] = (2020, 2030);
bounds[(:hgt, :cm)] = (150, 193);
bounds[(:hgt, :in)] = (59, 76);

# regexes
regex = Dict();
regex[:byr] = regex[:iyr] = regex[:eyr] = r"^[0-9]{4}$";
regex[:hgt] = r"^([0-9]+.?[0-9]+)(in|cm)$";
regex[:hcl] = r"^#[0-9a-f]{6}$";
regex[:pid] = r"^[0-9]{9}$";
regex[:ecl] = r"^(amb|blu|brn|gry|grn|hzl|oth)$";

# validation code for given field
function validate(field::Symbol, data)
  m = match(regex[field], data[field]);
  if m == nothing
    return false
  elseif haskey(bounds, field) # if it is a regular bound
    lb, ub = bounds[field];
    value = parse(Int, data[field]);
    return lb <= value <= ub;
  elseif field == :hgt
    value_str, unit_str = m.captures;
    value = parse(Float64, value_str);
    unit = Symbol(unit_str);
    lb, ub = bounds[(:hgt, unit)];
    return lb <= value <= ub;
  else # if field is hcl, pid, or ecl
    return true
  end
end

# checks whether the passport data is valid
function is_valid(data::Dict{Symbol, Any})
  for field in mandatory_fields
    value = get(data, field, nothing)
    if value == nothing
      return false
    else
      if !validate(field, data)
        return false
      end
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