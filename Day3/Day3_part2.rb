#!/usr/bin/ruby
# frozen_string_literal: true

input = 'input'

# define slope class
class Slope
  attr_reader :right, :down
  def initialize(right, down)
    @right = right
    @down = down
  end
end

slopes = []
slopes << Slope.new(1, 1)
slopes << Slope.new(3, 1)
slopes << Slope.new(5, 1)
slopes << Slope.new(7, 1)
slopes << Slope.new(1, 2)

# check if character is # or X, which means it is a tree
def is_tree?(c)
  %w[# X].include?(c)
end

x = [0]*slopes.length # horizontal position for each slope check
trees = [0]*slopes.length # tree counter for each slope
File.open(input) do |file|
  file.readlines.each_with_index do |line, row|
    line = line.chomp # remove trailing newline
    width = line.length # get width of mountain
    # check if row is valid row to check for tree
    slopes.each_with_index do |slope, i|
      # proceed only if row is valid for slope
      next unless (row % slope.down).zero?

      # don't move right for first row
      x[i] = (x[i] + slope.right) % width unless row.zero?
      # check if tree and update counter
      trees[i] += 1 if is_tree?(line[x[i]])
      # mark position
      line[x[i]] = (is_tree?(line[x[i]]) ? 'X' : 'O')
    end
    puts "#{line}:#{row}" # print row
  end
end
puts "Trees encountered: #{trees}" # output result
puts "Tree product: #{trees.reduce(:*)}"