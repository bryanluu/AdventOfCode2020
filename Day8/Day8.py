#!/bin/python3
from enum import Enum

filename = "input"

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

  # Checks if this line was potentially corrupted
  @staticmethod
  def might_be_corrupted(op):
    return op == Operation.NOP or op == Operation.JMP

# Enum for the different possible thread statuses
class ThreadStatus(Enum):
  RUNNING = 0 # if this thread can advance
  LOOPING = 1 # if this thread has looped
  FINISHED = 2 # if this thread has finished

class Thread:
  run = {} # function dictionary for each operation
  # increase accumulator and move to next line
  run[Operation.ACC] = lambda i, a, x: (i+1, a+x)
  # increase i by x and keep a
  run[Operation.JMP] = lambda i, a, x: (i+x, a)
  # move to next line
  run[Operation.NOP] = lambda i, a, x: (i+1, a)

  def __init__(self, host):
    self.host = host
    self.swapped = None
    self.i = 0
    self.a = 0
    self.ran = set()
    self.status = ThreadStatus.RUNNING

  # advance the current thread
  def advance(self):
    line = self.host.lines[self.i] # get the line of the program
    cmd, arg_str = line.split()
    arg = int(arg_str)
    self.execute(cmd, arg)
    self.update_status()

  # execute the cmd with arg on the thread
  def execute(self, cmd, arg):
    self.ran.add(self.i)
    op = Operation(cmd)
    if Operation.might_be_corrupted(op):
      if self.swapped == None and self.i not in self.host.branched:
        self.branch() # create new thread if this is the main branch
      elif self.swapped == self.i: # it is a branched thread
        op = Operation.swap(op) # swap this line if it should be swapped
    # update pointer and accumulator
    self.i, self.a = Thread.run[op](self.i, self.a, arg)

  # Update program status
  def update_status(self):
    if self.finished():
      self.status = ThreadStatus.FINISHED
    elif self.i in self.ran:
      self.status = ThreadStatus.LOOPING
    else:
      self.status = ThreadStatus.RUNNING

  # Creates a new thread where the current line is swapped (fixed)
  def branch(self):
    new = Thread(self.host)
    new.swapped = new.i = self.i
    new.a = self.a
    new.ran = self.ran.copy()
    self.host.branched.add(self.i)
    self.host.threads.append(new)

  def finished(self):
    return self.i == len(self.host.lines)

# Program class that holds 'threads' to run the program
class Program:
  # initialize the program
  def __init__(self, lines, verbose=False):
    self.lines = lines
    self.main = Thread(self)
    self.threads = [self.main]
    self.branched = set()
    self.verbose = verbose
    self.correct = None # The correct thread that finishes


  # advance all the threads
  def step(self):
    t = 0
    exit = False
    while t < self.thread_count():
      thread = self.threads[t]
      self.log(f"Thread {t}"\
          + (f" (swapped line {thread.swapped})" if t > 0 else "")
          + f": {thread.status}, i={thread.i}, a={thread.a}")
      if thread.status == ThreadStatus.RUNNING:
        thread.advance()
      else:
        if thread.status == ThreadStatus.FINISHED:
          self.correct = t
      self.completed = ((self.main.status == ThreadStatus.LOOPING)\
        and (self.correct != None))
      if self.completed:
        exit = True
        break
      else:
        if self.correct == None:
          t += 1 # move to next thread
        else:
          t = 0 # only run the main thread
    return exit

  def run(self, max_iter=None):
    self.log("===START===")
    it = 0 # loop iteration number
    while max_iter == None or it < max_iter:
      self.log(f"---Iteration {it}---")
      it += 1
      self.log(f"# Threads: {self.thread_count()}")
      self.step()
      if self.completed:
        break
    if self.completed:
      self.log("===END===")
      self.log(f"Main accumulator: {self.main.a}") # print final main accumulator
      correct_thread = self.threads[self.correct]
      self.log(f"Thread {self.correct} finished "
            f"(swapped line {correct_thread.swapped}): "
            f"i={correct_thread.i}, a={correct_thread.a}")
    else:
      self.log("*** MAX ITERATION REACHED ***")
      self.log(f"Program was not able to finish under {max_iter} iterations.")

  def log(self, msg):
    if self.verbose:
      print(msg)

  def thread_count(self):
    return len(self.threads)

  def get_finishing_thread(self):
    if self.correct == None:
      return None
    else:
      return self.threads[self.correct]

def solve(filename):
  with open(filename) as file:
    lines = file.readlines() # lines of the code
    program = Program(lines, False)
    program.run()
    Part1 = program.main.a
    Part2 = program.get_finishing_thread().a
    print(f"Part 1: {Part1}")
    print(f"Part 2: {Part2}")


if __name__ == '__main__':
  print(f"Input file: {filename}")
  import time
  start = time.time()
  solve(filename)
  end = time.time()
  print(f"Solve time: {end-start} seconds")