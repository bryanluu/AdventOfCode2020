filename = (isempty(ARGS) ? "input" : ARGS[1]); # Input file

# Calculates n choose k, unused
function nCk(n::Int, k::Int)
  if n < k
    return nothing
  end
  m, M = min(k, n-k), max(k, n-k);
  if m == 1
    return n;
  end
  return Int(prod(M+1:n)/prod(1:m));
end

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
    # For part 2 I exploit the fact that differences only contains 1 or 3, and adaptors with ratings 3 jolts apart
    # cannot be changed.
    j = 0; # index of last 3, initialized to 0
    arrangements = big(1);
    # Loop over differences and calculate the number of configurations to add the 1's in between 3's
    for (i, d) in enumerate(differences)
      if d == 3
        spaces = max(i - j - 2, 0);
        configs = Int(1 + spaces + (spaces-1)*spaces/2); # nCk(spaces, 0) + nCk(spaces, 1) + nCk(spaces, 2)
        arrangements *= configs;
        # (spaces > 0) ? println("$(differences[j+1:i-1]): spaces=$spaces, configs=$configs") : nothing;
        j = i;
      end
    end

    println("Part 1: $(diffcount[1]*diffcount[3])")
    println("Part 2: $arrangements")
  end
end

# run if script is run
if abspath(PROGRAM_FILE) == @__FILE__
  println("Input file: $(filename)")
  @time solve(filename); # Time the solve attempt
end