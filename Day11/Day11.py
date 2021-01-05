#!/bin/python3
import sys
import numpy as np
filename = sys.argv[1] if len(sys.argv) > 1 else "input"

FLOOR = "."
EMPTY = "L"
OCCUPIED = "#"

def show_grid(grid):
  for row in grid:
    print(" ".join(map(str, row)))

def get_potential_changed(seats, positions, changed):
  rows, cols = changed.shape
  check = changed.copy()
  for r, c in positions[changed]:
    adjacent = np.array([(r-1, c-1), (r-1, c), (r-1, c+1), (r, c-1),
        (r, c+1), (r+1, c-1), (r+1, c), (r+1, c+1)])
    valid = np.all(adjacent >= 0, axis=1) & (adjacent[:,0] < rows) & (adjacent[:,1] < cols)
    for neighbor in adjacent[valid]:
      nr, nc = neighbor
      check[nr, nc] = True if seats[nr, nc] != FLOOR else False
  return check

def simulate_round(seats, positions, check):
  rows, cols = seats.shape
  simulation = seats.copy()
  changed = np.zeros(seats.shape, dtype=bool)
  for r, c in positions[check]:
    seat = seats[r, c]
    adjacent = np.array([(r-1, c-1), (r-1, c), (r-1, c+1), (r, c-1),
      (r, c+1), (r+1, c-1), (r+1, c), (r+1, c+1)])
    valid = np.all(adjacent >= 0, axis=1) & (adjacent[:,0] < rows) & (adjacent[:,1] < cols)
    neighbors = np.array([seats[i, j] for i, j in adjacent[valid]])
    # print(f"r: {r}, c: {c}, neighbors: {neighbors}")
    if seat == EMPTY and np.all(neighbors != OCCUPIED):
      simulation[r, c] = OCCUPIED # occupy seat
      changed[r, c] = True
    elif seat == OCCUPIED and np.sum(neighbors == OCCUPIED) >= 4:
      simulation[r, c] = EMPTY # empty seat
      changed[r, c] = True
  return changed, simulation

def solve(filename):
  seats = []
  with open(filename) as file:
    for line in file:
      line = line.rstrip()
      seats.append([c for c in line])
  seats = np.array(seats)
  rows, cols = seats.shape
  positions = np.array([[(r, c) for c in range(cols)] for r in range(rows)])
  check = (seats != FLOOR)
  round = 0
  print("---Initial Layout---")
  show_seats(seats)
  print("===Simulation Begin===")
  while True:
    changed, simulation = simulate_round(seats, positions, check)
    if np.any(changed):
      round += 1
      print(f"---Round {round}---")
      seats = simulation
      show_seats(seats)
      check = get_potential_changed(seats, positions, changed)
      print(f"Changed: {positions[changed].tolist()}")
      # show_seats(changed)
      print(f"To check: {positions[check].tolist()}")
      # show_seats(check)
      print(f"{np.sum(check)}")
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