filename = (isempty(ARGS) ? "input" : ARGS[1]); # Input file

# Solves the challenge with input filename
function solve(filename)
  
end

# run if script is run
if abspath(PROGRAM_FILE) == @__FILE__
  println("Input file: $(filename)")
  @time solve(filename); # Time the solve attempt
end