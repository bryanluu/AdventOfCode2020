#!/bin/python3

if __name__ == '__main__':
  with open("input") as f:
    pw_list = f.readlines() # list of input passwords
    # pw_list = ["1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc"]
    vc = 0 # valid count
    for line in pw_list:
      policy, password = line.split(":")
      bounds, letter = policy.split(" ") # get bounds and the character
      lb, ub = bounds.split("-") # get lower/upper count bounds
      pw = password[1:] # remove whitespace at front

      valid = False
      count = 0
      # loop through the password, count the matching letters,
      # update valid flag accordingly
      for c in pw:
        if c == letter:
          count += 1
        if count >= int(lb) and not valid:
          valid = True
        if count > int(ub):
          valid = False
          break
        
      if valid:
        vc += 1
    print("Valid: {0}".format(vc))
