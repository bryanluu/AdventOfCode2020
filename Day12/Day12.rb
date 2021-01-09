#!/usr/bin/ruby
# frozen_string_literal: true

filename = (ARGV.empty? ? 'input' : ARGV.first)
part = 1
ARGV.length > 1 && part = ARGV[1].to_i

def deg2rad(degrees)
  (degrees / 180.0) * Math::PI
end

def rad2deg(radians)
  (radians / Math::PI) * 180
end

# Basic vector class in the 2D cartesian plane
class Vector
  attr_reader :x, :y, :angle, :length

  # Constructors

  def initialize(x, y)
    @x = x
    @y = y
    @angle = rad2deg(Math.atan2(y, x))
    @length = Math.sqrt(x * x + y * y)
  end

  def self.zero
    Vector.new(0, 0)
  end

  def self.create_from_angle(angle, length = 1)
    v = Vector.zero
    v.length = length
    v.angle = angle
    v
  end

  # Setters

  def x=(x)
    @x = x
    @angle = rad2deg(Math.atan2(@y, @x))
    @length = Math.sqrt(@x * @x + @y * @y)
  end

  def y=(y)
    @y = y
    @angle = rad2deg(Math.atan2(@y, @x))
    @length = Math.sqrt(@x * @x + @y * @y)
  end

  def angle=(angle)
    @angle = angle
    radians = deg2rad(angle)
    @x = @length * Math.cos(radians)
    @y = @length * Math.sin(radians)
  end

  def length=(length)
    if @length.zero?
      radians = deg2rad(@angle)
      @x = length * Math.cos(radians)
      @y = length * Math.sin(radians)
    else
      scale = Float(length) / @length
      @x *= scale
      @y *= scale
    end
    @length = length
  end

  # Add in-place, modifying vector
  def add!(other)
    @x += other.x
    @y += other.y
    @angle = rad2deg(Math.atan2(@y, @x))
    @length = Math.sqrt(@x * @x + @y * @y)
  end

  # Returns a new vector that is the addition
  def +(other)
    Vector.new(@x + other.x, @y + other.y)
  end

  # Returns a new vector that is the subtraction
  def -(other)
    Vector.new(@x - other.x, @y - other.y)
  end

  # Returns the scalar multiple of vector
  def *(other)
    Vector.new(other * @x, other * @y)
  end

  # String representation
  def to_s
    "(#{@x}, #{@y})"
  end
end

# Implements a ship
class Ship
  attr_accessor :position
  attr_reader :waypoint

  # Constructor
  def initialize(use_waypoint: false)
    @position = Vector.zero
    @direction = (use_waypoint ? nil : Vector.new(1, 0)) # East by default
    @waypoint = (use_waypoint ? Waypoint.new : nil)
    @compass = { 'N' => Vector.new(0, 1),
                 'S' => Vector.new(0, -1),
                 'W' => Vector.new(-1, 0),
                 'E' => Vector.new(1, 0),
                 'F' => (use_waypoint ? @waypoint.position : @direction) }
    @mover = (use_waypoint ? @waypoint : self)
    @turner = (use_waypoint ? @waypoint.position : @direction)
  end

  def waypoint?
    !@waypoint.nil?
  end

  def move(action, amount)
    obj = (action == 'F' ? self : @mover)
    movement = @compass[action]
    obj.position.add!(movement * amount)
  end

  def turn(towards, amount)
    @turner.angle += ((towards == 'L' ? 1 : -1) * amount)
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

# Implements a Waypoint
class Waypoint
  attr_accessor :position

  def initialize
    @position = Vector.new(10, 1)
  end
end

def solve(filename, part)
  ship = Ship.new(use_waypoint: part == 2)
  File.open(filename) do |file|
    until file.eof?
      instruction = file.readline.chomp
      ship.follow(instruction)
      puts "ship: #{ship.position}"
      puts "waypoint: #{ship.waypoint.position}" if ship.waypoint?
    end
  end
  manhattan = ship.position.x.abs + ship.position.y.abs
  puts "Ship's Manhattan distance (part #{part}): #{manhattan.round}"
end

if __FILE__ == $PROGRAM_NAME
  require 'benchmark'
  puts "Input file: #{filename}"
  puts "Part #{part}"
  time = Benchmark.realtime { solve(filename, part) }
  puts "solve(#{filename}) took #{time} seconds..."
end
