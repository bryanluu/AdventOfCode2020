#!/bin/python3

if __name__ == '__main__':
  with open("input") as f:
    pw_list = f.readlines() # list of input passwords
    # pw_list = ["1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc"]
    vc = 0 # valid count
    for line in pw_list:
      policy, password = line.split(":")
      indices, letter = policy.split(" ") # get bounds and the character
      i, j = map(lambda x: int(x), indices.split("-")) # get indices

      # perform the XOR of whether the i/jth letter matches to check validity
      valid = (password[i] == letter)^(password[j] == letter)
        
      if valid:
        vc += 1
    print("Valid: {0}".format(vc))
