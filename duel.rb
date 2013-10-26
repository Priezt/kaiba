require './tools'
require './command'
require './card_common'
require './card'
require './card_filter'
require './player'
require './zone'
require './timing'
require './deck'
require './side'
require './board'
require './hooks'
require './duel_timing'

class Duel
	bucket :players
	attr_accessor :board
	attr_accessor :turn_count


	attr_accessor :first_player
	attr_accessor :turn_player
	attr_accessor :priority_player

	def switch_priority
		@priority_player = @priority_player.opponent
		log "switch priority player to: #{@priority_player}"
	end

	def opponent_player
		self.turn_player.opponent
	end

	alias tp turn_player
	alias op opponent_player

	def switch_player
		@turn_player = @turn_player.opponent
		log "switch player to: #{@turn_player}"
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

	def query_all_commands
		[]
	end

	def query_all_cards
		log "query all cards"
		commands = get_all_commands
		if commands.length > 0
			goto :choose_command, :commands => commands, :priority_player => @td[:priority_player]
		end
		commands.length
	end

	def query_player(player)
		log "query player: #{player}"
		commands = player.get_commands
		if commands.length > 0
			goto :choose_command, :commands => commands, :priority_player => @td[:priority_player]
		end
	end
end
