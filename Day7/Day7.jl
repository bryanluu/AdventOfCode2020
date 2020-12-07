filename = "input"; # Input file
# Regular expression for inner bag parsing
re_bag = r"([0-9])\s([a-z][a-z\s]*)\sbag[s]?";
# Color of my bag
my_bag = "shiny gold";

# Create a dictionary mapping the bag color to the number from inside string
function parse_inner(inside::S) where {S <: AbstractString}
  bags = Dict{String, Int}();
  for m in eachmatch(re_bag, inside)
    numstr, color = m.captures;
    number = parse(Int, numstr);
    bags[color] = number;
  end
  return bags;
end

# Parse the rule, updating the rules and possible dictionaries
function parse_rule!(rule::String, rules::Dict{String, Dict{String, Int}},
    possible::Dict{String, Bool})
  outside, inside = strip.(split(rule, "contain"));
  outer = strip(outside[1:end-length("bags")]);
  bags = parse_inner(inside);
  rules[outer] = bags;
  if my_bag in keys(bags) || any(get(possible, bag, false) for bag in keys(bags))
    possible[outer] = true;
  end
end

# Returns if the bag may contain my bag, uses BFS
function may_contain(bag::String, bags::Dict{String, Dict{String, Int}},
    possible::Dict{String, Bool})
  q = [bag];
  while !isempty(q)
    bag = popfirst!(q);
    if get(possible, bag, false)
      return true;
    else
      for b in keys(bags[bag])
        push!(q, b);
      end
    end
  end
  return false;
end

# Helper function for DFS of bags
function _bag_count(color::String, bags::Dict{String, Dict{String, Int}})
  bagsum = 0;
  for (bag, num) in bags[color]
    bagsum += num * _bag_count(bag, bags);
  end
  return bagsum + 1;
end

# Number of bags inside bag of color
function bag_count(color::String, bags::Dict{String, Dict{String, Int}})
  return _bag_count(color, bags) - 1;
end

# Solves the challenge with input filename
function solve(filename)
  rules = Dict{String, Dict{String, Int}}();
  possible = Dict{String, Bool}();
  open(filename) do file
    while !eof(file)
      line = readline(file);
      parse_rule!(line, rules, possible);
    end
    for bag in keys(rules)
      if may_contain(bag, rules, possible)
        possible[bag] = true;
      end
    end
  end
  println("Number of possible bags: $(length(possible)) (Part 1)");
  println("Bag count: $(bag_count(my_bag, rules)) (Part 2)");
end

# run if script is run
if abspath(PROGRAM_FILE) == @__FILE__
  @time solve(filename);
end