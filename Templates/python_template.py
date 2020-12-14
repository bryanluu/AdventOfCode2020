#!/bin/python3
import sys
filename = sys.argv[1] if len(sys.argv) > 1 else "input"

def solve(filename):
  pass # DO STUFF

if __name__ == '__main__':
  print(f"Input file: {filename}")
  import time
  start = time.time()
  solve(filename)
  end = time.time()
  print(f"Solve time: {end-start} seconds")