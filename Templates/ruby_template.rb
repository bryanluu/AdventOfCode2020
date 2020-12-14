#!/usr/bin/ruby
# frozen_string_literal: true

filename = (ARGV.empty? ? 'input' : ARGV.first)

def solve(filename)
  # SOLVE
end

if __FILE__ == $PROGRAM_NAME
  require 'benchmark'
  puts "Input file: #{filename}"
  time = Benchmark.realtime { solve(filename) }
  puts "solve(#{filename}) took #{time} seconds..."
end
