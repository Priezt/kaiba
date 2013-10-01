require 'tools'

class Deck
	attr_accessor :main_deck
	attr_accessor :extra_deck

	def initialize(&block)
		@main_deck ||= []
		@extra_deck ||= []
		if block
			self.instance_eval &block
		end
	end

	def dump
		"Main: #{
			@main_deck.collect do |c|
				c.to_s
			end.join ", "
		}\nExtra: #{
			@extra_deck.collect do |c|
				c.to_s
			end.join ", "
		}\n"
	end
end

class Card
	def self.properties
		[
			:name,
			:type,
			:sub_type,
			:level,
			:attack,
			:defend,
			:text,
			:rank,
		]
	end

	module PropertyMethods
		Card.properties.each do |p|
			define_method p do |*args|
				if args.length == 0
					eval "@#{p.to_s}"
				else
					eval "@#{p.to_s} = args[0]"
				end
			end
		end
	end

	def self.[](card_name)
		eval("Card::#{card_name.to_s}").new
	end

	extend Card::PropertyMethods
	include Card::PropertyMethods

	def initialize
		self.class.properties.each do |p|
			self.send p, (self.class.send p)
		end
		@face = :down
		@position = :vertical
	end

	def to_s
		@name
	end
end
require 'card'

class Player
	include NameToString
	attr_accessor :deck
	attr_accessor :life_point

	def initialize(name)
		@name = name
		@life_point = 8000
	end

	def dump
		result = ""
		result += "#{@name}\n"
		result += deck.dump
		result
	end
end

class Timing; end
class << Timing
	attr_accessor :debug
	attr_accessor :enter_proc
	attr_accessor :leave_proc

	def create(classname, &block)
		create_raw(classname) do
			enter &block
		end
	end

	def create_raw(classname, &block)
		self.const_set classname.to_s.camel, Class.new(Timing){ }
		if block
			(self.const_get classname.to_s.camel).class_eval &block
		end
	end

	def enter(&block)
		@enter_proc = block
	end

	def leave(&block)
		@leave_proc = block
	end
end
class Timing
	self.debug = false
end
require 'timing'


class Side
	bucket :zones
	attr_accessor :player

	def initialize(p)
		self.player = p
		zones << Zone.new("deck")
		zones << Zone.new("extra")
		zones << Zone.new("hand")
		zones << Zone.new("field")
		zones << Zone.new("graveyard")
		zones << Zone.new("remove")
		(1..5).each do |n|
			zones << Zone.new("monster:#{n}")
			zones << Zone.new("spell:#{n}")
		end
	end

	def dump
		"#{player}: " + (zones.collect do |z|
			z.dump
		end.join " ")
	end
end

class Board
	bucket :sides

	def add_side(p)
		self.sides << Side.new(p)
	end

	def dump
		sides.collect do |s|
			s.dump + "\n"
		end.join ""
	end
end

class Zone
	include NameToString
	attr_accessor :cards

	def initialize(name)
		@name = name
		self.cards ||= []
	end

	def dump
		"#{@name}(#{self.cards.count})"
	end
end

class Duel
	bucket :players
	attr_accessor :board
	attr_reader :timing
	attr_accessor :turn_player
	attr_accessor :phase
	attr_accessor :turn_count
	attr_accessor :first_player

	def next_timing=(new_timing)
		@next_timing = eval "Timing::#{new_timing.to_s.camel}.new"
	end

	def run_timing
		if not @timing
			if Timing.debug
				puts "First Timing"
			end
		end
		@timing = @next_timing
		@td = @next_timing_data
		@next_timing = nil
		if Timing.debug
			puts "enter #{@timing.class.to_s}"
		end
		self.instance_eval &(@timing.class.enter_proc)
		if @timing.class.leave_proc
			self.instance_eval &(@timing.class.leave_proc)
		end
	end

	def goto(new_timing, args)
		self.next_timing = new_timing
		@next_timing_data = args
	end

	def initialize(p1, p2)
		self.players << p1
		self.players << p2
		self.board = Board.new
		self.board.add_side p1
		self.board.add_side p2
		self.turn_player = p1
	end

	def dump
		result = ""
		result += self.board.dump
		result
	end

	def start(start_timing = :prepare_game)
		self.next_timing = start_timing
		while true
			self.run_timing
			if not @next_timing
				break
			end
		end
	end
end
