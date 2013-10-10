require './tools'

class Command
	attr_accessor :player, :type, :data

	def initialize(player, type, args={})
		@player = player
		@type = type
		@data = args
	end

	def to_s
		"#{@player}:#{@type}{#{
			@data.each_key.map{|k|
				"#{k}=>#{@data[k].to_s}"
			}.join ","
		}}"
	end
end

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
	def self.inherited(base)
		# TODO:  inherit properties
		# @properties ||= superclass.class_eval{@properties}
		ancstrs = base.ancestors.clone
		ancstrs.shift
		base.properties ||= []
		base.properties += ancstrs.find{|c| c.to_s =~ /Card$/}.properties
	end
end
class << Card
	attr_accessor :properties

	def add_prop(sym)
		@properties ||= []
		@properties << sym
		define_method sym do |*args|
			if args.length == 0
				eval "@#{sym.to_s}"
			else
				eval "@#{sym.to_s} = args[0]"
			end
		end
		define_singleton_method sym do |*args|
			if args.length == 0
				eval "@#{sym.to_s}"
			else
				eval "@#{sym.to_s} = args[0]"
			end
		end
	end
end
class Card
	attr_accessor :duel
	attr_accessor :player
	attr_accessor :zone

	add_prop :name
	add_prop :text

	def self.[](card_name)
		eval("Card::#{card_name.to_s}").new
	end

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

	def method_missing(method_name, *args, &block)
		self.class.send method_name, *args, &block
	end

	include DuelLog
	extend DuelLog
end
require './card_common'
require './card'

class Player
	include NameToString
	attr_accessor :duel
	attr_accessor :deck
	attr_accessor :life_point
	attr_accessor :side
	attr_accessor :normal_summon_allowed_count

	[
		'deck',
		'extra',
		'hand',
		'graveyard',
		'field',
		'remove',
	].each do |z|
		define_method "#{z}_zone" do
			side.zones[z]
		end
	end
	[
		'monster',
		'spell',
	].each do |z|
		define_method "#{z}_zones" do
			(1..5).to_a.map do |n|
				side.zones["#{z}:#{n}"]
			end
		end
	end

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

	include DuelLog
	extend DuelLog
end
require './player_action'

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

	def is(sym)
		self.class.to_s.sub(/.*\:/, "") == sym.to_s.camel
	end
end
require './timing'

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
		c = self.cards.pop
		c.zone = nil
		c
	end

	def push(c)
		self.cards.push c
		c.zone = self
	end

	def clear
		self.cards = []
	end

	def shuffle
		@cards = @cards.sort_by do |c|
			rand
		end
	end

	def available?
		cards.length == 0
	end
end

class Duel
	bucket :players
	attr_accessor :board
	attr_accessor :turn_player
	attr_accessor :turn_count
	attr_accessor :first_player
	attr_accessor :current_timing
	attr_accessor :td

	def opponent_player
		self.players.each_value do |p|
			if p != self.turn_player
				return p
			end
		end
	end

	alias tp turn_player
	alias op opponent_player

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
		log "switch player to: #{sorted_player_names[next_index]}"
		@turn_player = self.players[sorted_player_names[next_index]]
	end

	def run_timing
		@current_timing = @timing_stack.pop
		@td = @current_timing.timing_data
		log "enter #{@current_timing.class.to_s}"
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
		p1.duel = self
		p2.duel = self
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
		log "no timing left"
	end

	def end?
		@timing_stack ||= []
		@timing_stack.length == 0
	end

	def under(timing_sym)
		([@current_timing] + @timing_stack).find do |t|
			t.class.to_s.sub(/.*\:/, '') == timing_sym.to_s.camel
		end
	end

	def get_all_commands
		commands = []
		commands += tp.get_commands
		commands += op.get_commands
		commands += tp.get_all_card_commands
		commands += op.get_all_card_commands
		log "[#{commands.map do |c|
			c.to_s
		end.join ", "}]"
		commands
	end

	include DuelLog
end
