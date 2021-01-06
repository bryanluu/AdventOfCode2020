#!/bin/python3
import sys
import numpy as np
filename = sys.argv[1] if len(sys.argv) > 1 else "input"

part = (int(sys.argv[2]) if len(sys.argv) > 2 else None)
while part is None:
  print("Part 1 or 2?")
  reply = input("Choose: ")
  part = (int(reply) if reply == "1" or reply == "2" else None)

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
  neighbors = np.zeros(seats.shape, dtype=bool)
  rows, cols = seats.shape
  adjacent = np.array([(r+i, c+j) for i in range(-1, 2) for j in range(-1, 2)
    if 0 <= r+i < rows and 0 <= c+j < cols and not (i == 0 and j == 0)])
  for nr, nc in adjacent:
    neighbors[nr, nc] = True
  return adjacent, neighbors

# Gets visible seats from seat at r, c
def get_visible_chairs(seats, r, c):
  neighbors = np.zeros(seats.shape, dtype=bool)
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
  for nr, nc in visible[ok]:
    neighbors[nr, nc] = True
  return visible[ok], neighbors

def initialize_neighbors(seats, positions):
  neighbors = {}
  for r, c in positions[seats != FLOOR]:
    neighbors[r, c] = (get_adjacent(seats, r, c) if part == 1 else get_visible_chairs(seats, r, c))
  return neighbors

# Simulate one round of seating
def simulate_round(seats, positions, neighbors):
  limit = (4 if part == 1 else 5)
  simulation = seats.copy()
  flipped = np.where(seats == EMPTY, np.full(seats.shape, OCCUPIED), 
    np.where(seats == OCCUPIED, np.full(seats.shape, EMPTY), np.full(seats.shape, FLOOR)))
  changed = np.zeros(seats.shape, dtype=bool)
  occupied = np.zeros(seats.shape, dtype=int)
  if np.all(seats != OCCUPIED): # if no seats are occupied
    chairs = (seats == EMPTY)
    simulation[chairs] = OCCUPIED
    changed[chairs] = True
  else: # else check each position that might change
    for r, c in positions[seats != FLOOR]:
      _, isneighbor = neighbors[r, c]
      occupied[r, c] = np.sum((seats[isneighbor] == OCCUPIED))
    changed = (((seats == EMPTY) & (occupied == 0)) | ((seats == OCCUPIED) & (occupied >= limit)))
    simulation = np.where(changed, flipped, seats)
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
  round = 0
  print("---Initial Layout---")
  show_grid(seats)
  print("Building neighbor list...")
  neighbors = initialize_neighbors(seats, positions)
  print("===Simulation Begin===")
  while True:
    changed, simulation = simulate_round(seats, positions, neighbors) # simulate round
    if np.any(changed): # if any seat changed, continue, otherwise, finish
      round += 1
      print(f"---Round {round}---")
      seats = simulation
      show_grid(seats)
    else:
      break
  print(f"===Simulation Ended after {round} rounds===")
  print(f"Part {part} # occupied: {np.sum(seats == OCCUPIED)}")
          
if __name__ == '__main__':
  print(f"Input file: {filename}")
  import time
  start = time.time()
  solve(filename)
  end = time.time()
  print(f"Solve time: {end-start} seconds")