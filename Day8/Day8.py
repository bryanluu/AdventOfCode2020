#!/bin/python3
filename = "input"

def solve(filename):
  with open(filename) as file:
    lines = file.readlines() # lines of the code
    Nlines = len(lines)
    done = set() # all executed lines
    i = 0 # current line position
    a = 0 # accumulator
    run = {} # function dictionary for each operation
    # increase accumulator and move to next line
    run["acc"] = lambda i, a, x: (i+1, a+x)
    # increase i by x and keep a
    run["jmp"] = lambda i, a, x: (i+x, a)
    # move to next line
    run["nop"] = lambda i, a, x: (i+1, a)
    print("---START---")
    while i not in done or i >= Nlines:
      line = lines[i]
      cmd, argstr = line.split()
      arg = int(argstr)
      done.add(i) # add this line to the executed list
      print(f"Ran line {i}: {lines[i].rstrip()}")
      i, a = run[cmd](i, a, arg) # update position and accumulator
      print(f"New (i, a): {(i, a)}")
    print("---END---")
    print(f"accumulator: {a}") # print final accumulator


if __name__ == '__main__':
  print(f"Input file: {filename}")
  import time
  start = time.time()
  solve(filename)
  end = time.time()
  print(f"Solve time: {end-start} seconds")