#!/bin/python3
import sys
import numpy as np
filename = sys.argv[1] if len(sys.argv) > 1 else "input"

FLOOR = "."
EMPTY = "L"
OCCUPIED = "#"

def simulate_round(seats):
  rows, cols = seats.shape
  simulation = seats.copy()
  changed = False
  for r, row in enumerate(seats):
    for c, seat in enumerate(row):
      adjacent = np.array([(r-1, c-1), (r-1, c), (r-1, c+1), (r, c-1),
        (r, c+1), (r+1, c-1), (r+1, c), (r+1, c+1)])
      valid = np.all(adjacent >= 0, axis=1) & np.all(adjacent < cols, axis=1)
      neighbors = np.array([seats[i, j] for i, j in adjacent[valid]])
      # print(f"r: {r}, c: {c}, neighbors: {neighbors}")
      if seat == EMPTY and np.all(neighbors != OCCUPIED):
        simulation[r, c] = OCCUPIED # occupy seat
        changed = True
      elif seat == OCCUPIED and np.sum(neighbors == OCCUPIED) >= 4:
        simulation[r, c] = EMPTY # empty seat
        changed = True
  return changed, simulation

def show_seats(seats):
  for row in seats:
    print("".join(row))

def solve(filename):
  seats = []
  with open(filename) as file:
    for line in file:
      line = line.rstrip()
      seats.append([c for c in line])
  seats = np.array(seats)
  round = 0
  print("---Initial Layout---")
  show_seats(seats)
  print("===Simulation Begin===")
  while True:
    changed, simulation = simulate_round(seats)
    if changed:
      round += 1
      print(f"---Round {round}---")
      seats = simulation
      show_seats(seats)
    else:
      break
  print(f"===Simulation Ended after {round} rounds===")
  print(f"# occupied: {np.sum(seats == OCCUPIED)}") # Part 1
          
if __name__ == '__main__':
  print(f"Input file: {filename}")
  import time
  start = time.time()
  solve(filename)
  end = time.time()
  print(f"Solve time: {end-start} seconds")