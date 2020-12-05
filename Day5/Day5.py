#!/bin/python3

UPPER = "BR"
ROWS = 127
COLS = 7

# function to convert boarding pass into binary string
def parse_seat(bp):
  bin_str = "".join(map(lambda c: '1' if c in UPPER else '0', bp))
  row = int(bin_str[0:-3], 2)
  col = int(bin_str[-3:], 2)
  return row, col

# function to calculate seat ID
def seatID(row, col):
  return 8 * row + col

if __name__ == '__main__':
  filename = "input"
  seats = {} # seats => IDs
  with open(filename) as file:
    # parse and calculate max seat ID
    maxID = -1
    my_seatID = -1
    for line in file:
      bp = line.rstrip() # get boarding pass
      row, col = parse_seat(bp)
      ID = seatID(row, col)
      seats[(row, col)] = ID
      if ID > maxID:
        maxID = ID

    # search for my seat
    takenIDs = seats.values()
    for row in range(1, ROWS-1):
      if my_seatID != -1: # my seat has been found
        break
      for col in range(COLS):
        if (row, col) not in seats:
          ID = seatID(row, col)
          if ID+1 in takenIDs and ID-1 in takenIDs:
            my_seatID = ID
            break

  # Print answers
  print("--- Part 1 ---")
  print(f"Max seat ID: {maxID}")
  print("--- Part 2 ---")
  print(f"My seat ID: {my_seatID}")
