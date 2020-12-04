#!/usr/bin/ruby
# frozen_string_literal: true

input = 'input'

# define slope to check
right = 3
down = 1

x_pos = 0 # start off at top-left corner
trees = 0 # tree count
File.open(input) do |file|
  file.readlines.each_with_index do |line, row|
    line = line.chomp # remove trailing newline
    width = line.length # get width of mountain
    # check if row is valid row to check for tree
    if (row % down).zero?
      # don't move right for first row
      x_pos = (x_pos + right) % width unless row.zero?
      trees += 1 if line[x_pos] == '#' # check if tree and update counter
      # mark position
      line[x_pos] = (line[x_pos] == '#' ? 'X' : 'O')
    end
    puts "#{line}:#{row}, x:#{x_pos}" # print row
  end
  puts "Trees encountered: #{trees}" # output result
end