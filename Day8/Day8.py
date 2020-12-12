#!/bin/python3
from enum import Enum

filename = "input"
MAX_ITERATIONS = 1000

# Enum class for the Operation names
class Operation(Enum):
  NOP = "nop"
  JMP = "jmp"
  ACC = "acc"

  # If the given Operation is NOP or JMP, return its counterpart
  # Otherwise returns itself (the given Operation)
  @staticmethod
  def swap(op):
    if op == Operation.NOP or op == Operation.JMP:
      return Operation.JMP if op == Operation.NOP else Operation.NOP
    else:
      return op

# Enum for the different possible thread statuses
class ThreadStatus(Enum):
  RUNNING = 0 # if this thread can advance
  LOOPING = 1 # if this thread has looped
  FINISHED = 2 # if this thread has finished

# Program singleton to hold 'threads' to run the program
class Program:
  threads = []
  lines = []
  branched = set()
  run = {} # function dictionary for each operation
  # increase accumulator and move to next line
  run[Operation.ACC] = lambda i, a, x: (i+1, a+x)
  # increase i by x and keep a
  run[Operation.JMP] = lambda i, a, x: (i+x, a)
  # move to next line
  run[Operation.NOP] = lambda i, a, x: (i+1, a)

  # initialize the singleton
  def __init__(self, lines=[]):
    if len(lines) > 0: # if new singleton is created
      Program.lines = lines
      Program.threads = [self]
      Program.branched = set()
    self.swapped = None
    self.i = 0
    self.a = 0
    self.ran = set()
    self.status = ThreadStatus.RUNNING

  # advance the current thread
  def advance(self):
    line = Program.lines[self.i] # get the line of the program
    cmd, arg_str = line.split()
    arg = int(arg_str)
    self.execute(cmd, arg)
    self.update_status()

  # execute the cmd with arg on the thread
  def execute(self, cmd, arg):
    self.ran.add(self.i)
    op = Operation(cmd)
    if Program.might_be_corrupted(op):
      if self.swapped == None and self.i not in Program.branched:
        self.branch() # create new thread if this is the main branch
      elif self.swapped == self.i: # it is a branched thread
        op = Operation.swap(op) # swap this line if it should be swapped
    # update pointer and accumulator
    self.i, self.a = Program.run[op](self.i, self.a, arg)

  # Update program status
  def update_status(self):
    if self.finished():
      self.status = ThreadStatus.FINISHED
    elif self.i in self.ran:
      self.status = ThreadStatus.LOOPING
    else:
      self.status = ThreadStatus.RUNNING

  # Checks if this line was potentially corrupted
  @staticmethod
  def might_be_corrupted(op):
    return op == Operation.NOP or op == Operation.JMP

  # Creates a new thread where the current line is swapped (fixed)
  def branch(self):
    new = Program()
    new.swapped = new.i = self.i
    new.a = self.a
    new.ran = self.ran.copy()
    Program.branched.add(self.i)
    Program.threads.append(new)

  def finished(self):
    return self.i == len(Program.lines)

def solve(filename):
  with open(filename) as file:
    lines = file.readlines() # lines of the code
    main = Program(lines)
    correct = None # The correct thread that finishes
    completed = False # Whether the program completed before MAX_ITERATIONS
    print("===START===")
    it = 0 # loop iteration number
    while it < MAX_ITERATIONS:
      t = 0
      print(f"---Iteration {it}---")
      it += 1
      print(f"# Threads: {len(Program.threads)}")
      while t < len(Program.threads):
        thread = Program.threads[t]
        print(f"Thread {t}"\
           + (f" (swapped line {thread.swapped})" if t > 0 else "")
           + f": {thread.status}, i={thread.i}, a={thread.a}")
        if thread.status == ThreadStatus.RUNNING:
          thread.advance()
        else:
          if thread.status == ThreadStatus.FINISHED:
            correct = t
        completed = ((main.status == ThreadStatus.LOOPING)\
          and (correct != None))
        if completed:
          break
        t += 1
      if completed:
        break
    if completed:
      print("===END===")
      print(f"(PART 1) Main accumulator: {main.a}") # print final main accumulator
      correct_thread = Program.threads[correct]
      print(f"(PART 2) Thread {correct} finished "
            f"(swapped line {correct_thread.swapped}): "
            f"i={correct_thread.i}, a={correct_thread.a}")
    else:
      print("*** MAX ITERATION REACHED ***")
      print(f"Program was not able to finish under {MAX_ITERATIONS} iterations.")


if __name__ == '__main__':
  print(f"Input file: {filename}")
  import time
  start = time.time()
  solve(filename)
  end = time.time()
  print(f"Solve time: {end-start} seconds")