#!/usr/bin/ruby
# frozen_string_literal: true

filename = (ARGV.empty? ? 'input' : ARGV.first)

def solve(filename)
  File.open(filename) do |file|
    preamble_length = (filename == 'input' ? 25 : 5) # length of preamble
    invalid = nil # the invalid number
    q = Hash.new(false) # queue of numbers
    list = [] # list of numbers

    # Obtain preamble
    1.upto(preamble_length).each do |_|
      number = file.readline.chomp.to_i
      q[number] = true
      list.push(number)
    end

    # Get rest of list and find invalid number
    until file.eof?
      number = file.readline.chomp.to_i
      if invalid.nil?
        valid = false
        start = q.first.first # get the number at the start
        q.each do |check, _|
          if q[number - check] # if a sum exists
            valid = true
            break
          end
        end
        if valid
          q.delete(start)
          q[number] = true
        else
          invalid = number
        end
      end
      list.push(number)
    end

    # Double loop to check through sums
    weakness = nil
    list[0...-1].each_with_index do |x, i|
      sum = x
      (i + 1).upto(list.length) do |j|
        sum += list[j]
        if sum > invalid
          break # this sum is too large
        elsif sum == invalid # found a sum
          min, max = list[i..j].minmax
          weakness = min + max
          break
        end
      end
      break unless weakness.nil? # loop until weakness found
    end

    puts "Invalid (Part 1): #{invalid}"
    puts "Weakness (Part 2): #{weakness}"
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'benchmark'
  puts "Input file: #{filename}"
  time = Benchmark.realtime { solve(filename) }
  puts "solve(#{filename}) took #{time} seconds..."
end
