#!/usr/bin/ruby
# frozen_string_literal: true

require 'set'

# Input file
input = 'input'

File.open(input) do |file|
  any_sum = all_sum = 0
  any = Set[] # set for part 1, keeps track of questions anyone answered
  # set for part 2, initialized to nil
  all = nil # keeps track of questions everyone answered
  until file.eof?
    line = file.readline.chomp
    if line.empty? # count any and all and add to sums
      any_sum += any.size
      any.clear
      all_sum += all.size
      all = nil
    else
      answered = Set[]
      all = answered if all.nil?
      line.split('').each do |question|
        answered.add(question)
      end
      any |= answered
      all &= answered
    end
  end
  any_sum += any.size
  all_sum += all.size
  puts "Part 1 sum: #{any_sum}"
  puts "Part 2 sum: #{all_sum}"
end
