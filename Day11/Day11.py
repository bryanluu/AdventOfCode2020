#!/bin/python3
import sys
import numpy as np
filename = sys.argv[1] if len(sys.argv) > 1 else "input"

# characters in problem statement
FLOOR = "."
EMPTY = "L"
OCCUPIED = "#"

# Show numpy grid
def show_grid(grid):
  for row in grid:
    print(" ".join(map(str, row)))

# Gets the adjacent surrounding seats of seat at r, c
def get_adjacent(seats, r, c):
  rows, cols = seats.shape
  adjacent = np.array([(r+i, c+j) for i in range(-1, 2) for j in range(-1, 2)
    if 0 <= r+i < rows and 0 <= c+j < cols and not (i == 0 and j == 0)])
  return adjacent

# Gets visible seats from seat at r, c
def get_visible_chairs(seats, r, c):
  rows, cols = seats.shape
  valid = lambda row, col: (0 <= row < rows and 0 <= col < cols and not (row == r and col == c)
    and seats[row, col] != FLOOR)
  first = lambda x: np.array(x[0], dtype=int) if len(x) > 0 else np.array([-1, -1], dtype=int)
  W = np.array([(r, c-i) for i in range(cols) if valid(r, c-i)], dtype=int)
  E = np.array([(r, c+i) for i in range(cols) if valid(r, c+i)], dtype=int)
  N = np.array([(r-i, c) for i in range(cols) if valid(r-i, c)], dtype=int)
  S = np.array([(r+i, c) for i in range(cols) if valid(r+i, c)], dtype=int)
  NW = np.array([(r-i, c-i) for i in range(cols) if valid(r-i, c-i)], dtype=int)
  NE = np.array([(r-i, c+i) for i in range(cols) if valid(r-i, c+i)], dtype=int)
  SW = np.array([(r+i, c-i) for i in range(cols) if valid(r+i, c-i)], dtype=int)
  SE = np.array([(r+i, c+i) for i in range(cols) if valid(r+i, c+i)], dtype=int)
  visible = np.stack((first(W), first(E), first(N), first(S),
    first(NW), first(NE), first(SE), first(SW)))
  ok = np.all(visible >= 0, axis=1)
  return visible[ok]

# Get potential seats that might change
def get_potential_changed(seats, positions, changed, part):
  check = changed.copy()
  for r, c in positions[changed]:
    neighbors = (get_adjacent(seats, r, c) if part == 1 else get_visible_chairs(seats, r, c))
    for neighbor in neighbors:
      nr, nc = neighbor
      check[nr, nc] = True if seats[nr, nc] != FLOOR else False
  return check

# Simulate one round of seating
def simulate_round(seats, positions, check, part):
  simulation = seats.copy()
  changed = np.zeros(seats.shape, dtype=bool)
  if np.all(seats != OCCUPIED): # if no seats are occupied
    chairs = (seats == EMPTY)
    simulation[chairs] = OCCUPIED
    changed[chairs] = True
  else: # else check each position that might change
    limit = (4 if part == 1 else 5)
    for r, c in positions[check]:
      seat = seats[r, c]
      neighbors = (get_adjacent(seats, r, c) if part == 1 else get_visible_chairs(seats, r, c))
      neighbors_seats = np.array([seats[i, j] for i, j in neighbors])
      # print(f"r: {r}, c: {c}, neighbors: {neighbors}, seats: {neighbors_seats}")
      if seat == EMPTY and np.all(neighbors_seats != OCCUPIED):
        simulation[r, c] = OCCUPIED # occupy seat
        changed[r, c] = True
      elif seat == OCCUPIED and np.sum(neighbors_seats == OCCUPIED) >= limit:
        simulation[r, c] = EMPTY # empty seat
        changed[r, c] = True
  return changed, simulation

def solve(filename, part):
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
  show_grid(seats)
  print("===Simulation Begin===")
  while True:
    changed, simulation = simulate_round(seats, positions, check, part) # simulate round
    if np.any(changed): # if any seat changed, continue, otherwise, finish
      round += 1
      print(f"---Round {round}---")
      seats = simulation
      show_grid(seats)
      check = get_potential_changed(seats, positions, changed, part) # seats to check for status
    else:
      break
  print(f"===Simulation Ended after {round} rounds===")
  print(f"Part {part} # occupied: {np.sum(seats == OCCUPIED)}")
          
if __name__ == '__main__':
  print(f"Input file: {filename}")
  import time
  start = time.time()
  part = (int(sys.argv[2]) if len(sys.argv) > 2 else None)
  while part is None:
    print("Part 1 or 2?")
    reply = input("Choose: ")
    part = (int(reply) if reply == "1" or reply == "2" else None)
  solve(filename, part)
  end = time.time()
  print(f"Solve time: {end-start} seconds")