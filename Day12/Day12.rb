#!/usr/bin/ruby
# frozen_string_literal: true

filename = (ARGV.empty? ? 'input' : ARGV.first)

def deg2rad(degrees)
  (degrees / 180.0) * Math::PI
end

def rad2deg(radians)
  (radians / Math::PI) * 180
end

# Basic unit vector class in the 2D cartesian plane
class UnitVector
  attr_accessor :angle

  def initialize(angle)
    @angle = angle
    radians = deg2rad(angle)
    @x = Math.cos(radians)
    @y = Math.sin(radians)
  end

  def x
    @x = Math.cos(deg2rad(@angle))
  end

  def y
    @y = Math.sin(deg2rad(@angle))
  end
end

# Implements a ship
class Ship
  attr_reader :east, :north

  def initialize
    @direction = UnitVector.new(0) # East
    @east = @north = 0
    @compass = { 'N' => UnitVector.new(90),
                 'S' => UnitVector.new(-90),
                 'W' => UnitVector.new(180),
                 'E' => UnitVector.new(0),
                 'F' => @direction }
  end

  def move(action, amount)
    puts "x: #{@compass[action].x}, y: #{@compass[action].y}"
    @east += (amount * @compass[action].x)
    @north += (amount * @compass[action].y)
  end

  def turn(towards, amount)
    @direction.angle += ((towards == 'L' ? 1 : -1) * amount)
  end

  def follow(instruction)
    puts instruction
    action = instruction[0]
    amount = instruction[1..].to_i
    if @compass.key? action
      move(action, amount)
    else
      turn(action, amount)
    end
  end
end

def solve(filename)
  File.open(filename) do |file|
    ship = Ship.new
    until file.eof?
      instruction = file.readline.chomp
      ship.follow(instruction)
      puts "east: #{ship.east}, north: #{ship.north}"
    end
    manhattan = ship.east.abs + ship.north.abs
    puts "Ship's Manhattan distance (Part 1): #{manhattan.round}"
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'benchmark'
  puts "Input file: #{filename}"
  time = Benchmark.realtime { solve(filename) }
  puts "solve(#{filename}) took #{time} seconds..."
end
