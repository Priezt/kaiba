require './tools'
require './command'
require './card_common'
require './card'
require './card_filter'
require './player'
require './zone'

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

	def to_s
		self.class.name.sub /.*:/, ''
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
		zones.each_value do |z|
			z.side = self
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

	def add_choose_hook(hook_proc)
		@choose_hooks ||= []
		@choose_hooks << hook_proc
	end

	def timing_hooks
		@timing_hooks ||= []
	end

	def choose_hooks
		@choose_hooks ||= []
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

	def dump_timing_stack
		"[#{
			@timing_stack.map do |t|
				t.to_s
			end.join ", "
		}]"
	end

	def run_timing
		@current_timing = @timing_stack.pop
		@td = @current_timing.timing_data
		log "enter #{@current_timing.class.to_s}"
		@last_data = self.instance_eval &(@current_timing.class.enter_proc)
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
		commands
	end

	def select_all_force_commands(commands, player)
		log "select all force commands for #{player}"
		commands.select  do |c|
			c.player == player
		end.select  do |c|
			c.data[:force]
		end
	end

	def select_all_optional_commands(commands, player)
		log "select all optional commands for #{player}"
		commands.select  do |c|
			c.player == player
		end.select  do |c|
			c.data[:optional]
		end
	end

	def choose_one_command(commands)
		log "about to choose one command: #{commands.count} commands"
		if commands.count == 0
			raise Exception.new("no command to choose")
		elsif commands.count == 1
			log "command chosen: #{commands[0]}"
			return commands[0]
		else
			if self.choose_hooks.count == 0
				raise Exception.new "no choose hook"
			end
			self.choose_hooks.each  do |ch|
				log "choose_hook: #{ch.inspect}"
				choose_result = ch.call commands # this shit cannot be fired, don't know why
				if choose_result
					log "command chosen: #{choose_result}"
					return choose_result
				end
			end
			raise Exception.new "no command has been chosen"
		end
	end

	def all_cards
		cards = []
		players.each_value do |p|
			cards += p.all_my_cards
		end
		cards
	end
end
