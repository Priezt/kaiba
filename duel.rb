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

	def clone
		Card[self.class.to_s.sub(/.*:/, "")]
	end
end
require 'card'

class Player
	include NameToString
	attr_accessor :deck
	attr_accessor :life_point
	attr_accessor :side

	def initialize(name)
		@name = name
		@life_point = 8000
	end

	def dump
		result = ""
		result += "#{@name}\n"
		#result += deck.dump
		result += side.dump
		result
	end
end
require 'player_action'

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

	attr_accessor :timing_data
end
require 'timing'

class Side
	bucket :zones
	alias zone zones
	attr_accessor :player

	def initialize(p)
		self.player = p
		p.side = self
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

	def pop
		self.cards.pop
	end

	def push(c)
		self.cards.push c
	end

	def clear
		self.cards = []
	end

	def shuffle
		@cards = @cards.sort_by do |c|
			rand
		end
	end
end

class Duel
	bucket :players
	attr_accessor :board
	attr_accessor :turn_player
	attr_accessor :phase
	attr_accessor :turn_count
	attr_accessor :first_player

	def opponent_player
		self.players.each_value do |p|
			if p != self.turn_player
				p
			end
		end
	end

	alias ore turn_player
	alias omae opponent_player

	def add_timing_hook(hook_proc)
		@timing_hooks ||= []
		@timing_hooks << hook_proc
	end

	def timing_hooks
		@timing_hooks ||= []
	end

	def switch_player
		sorted_player_names = self.players.collect do |p|
			p.to_s
		end.sort.to_a
		next_index = 1 + (sorted_player_names.find_index @turn_player.to_s)
		if next_index >= sorted_player_names.length
			next_index = 0
		end
		@turn_player = self.players[sorted_player_names[next_index]]
	end

	def run_timing
		@current_timing = @timing_stack.pop
		@td = @current_timing.timing_data
		if Timing.debug
			puts "enter #{@current_timing.class.to_s}"
		end
		self.instance_eval &(@current_timing.class.enter_proc)
		if @current_timing.class.leave_proc
			self.instance_eval &(@current_timing.class.leave_proc)
		end
		after_timing = Timing::AfterTiming.new
		after_timing.timing_data = @current_timing
		self.instance_eval &(after_timing.class.enter_proc)
	end

	def clear_timing_stack
		@timing_stack = []
	end

	def push_timing(new_timing_symbol, args={})
		@timing_stack ||= []
		if not eval("defined?(Timing::#{new_timing_symbol.to_s.camel})")
			Timing.class_eval do
				create new_timing_symbol do
				end
			end
		end
		new_timing = eval "Timing::#{new_timing_symbol.to_s.camel}.new"
		new_timing.timing_data = args
		@timing_stack.push new_timing
	end

	alias goto push_timing

	def push_multiple_timing(*new_timing_symbol_list)
		new_timing_symbol_list.reverse.each do |t|
			if t.class == Symbol
				goto t
			elsif t.class == Array
				goto *t
			else
				raise Exception.new "unexpected class"
			end
		end
	end

	alias stack push_multiple_timing

	def set_timing(new_timing_symbol, args)
		self.clear_timing_stack
		self.push_timing new_timing_symbol, args
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
		self.push_timing start_timing
		while @timing_stack.length > 0
			self.run_timing
		end
	end

	def end?
		@timing_stack ||= []
		@timing_stack.length == 0
	end

	def log(msg)
		File.open(",duel.log", "a") do |f|
			f.puts msg
		end
	end
end
