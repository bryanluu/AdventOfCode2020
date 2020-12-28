filename = (isempty(ARGS) ? "input" : ARGS[1]); # Input file

# Solves the challenge with input filename
function solve(filename)
  open(filename) do file
    adapters = [0];
    while !eof(file)
      line = readline(file);
      rating = parse(Int, chomp(line)); # joltage rating of adapter
      push!(adapters, rating);
    end
    sort!(adapters); # sort the adapters by joltage rating
    push!(adapters, last(adapters) + 3); # add built-in adapter
    differences = diff(adapters);
    diffcount = Dict(d => count((x)->x == d, differences) for d in unique(differences)); # count the differences
    println("Part 1: $(diffcount[1]*diffcount[3])")
  end
end

# run if script is run
if abspath(PROGRAM_FILE) == @__FILE__
  println("Input file: $(filename)")
  @time solve(filename); # Time the solve attempt
end