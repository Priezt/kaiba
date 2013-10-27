class Array
	def commands_for_player(player)
		log "select all commands for player: #{player}"
		self.select  do |c|
			c.player == player
		end
	end

	def force_commands
		log "select all force commands"
		self.select  do |c|
			c.data[:force]
		end
	end

	def optional_commands
		log "select all optional commands"
		self.select  do |c|
			c.data[:optional]
		end
	end
end

class Command
	attr_accessor :player, :type, :data

	def duel
		@player.duel
	end

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

	def execute
		log "execute command: #{self}"
		send "execute_#{@type}"
	end

	def execute_summon
		duel.goto :normal_summon_monster, :card => @data[:card]
	end

	def execute_advance_summon
		duel.goto :advance_summon_monster, :card => @data[:card]
	end

	def execute_monster_set
		duel.goto :normal_set_monster, :card => @data[:card]
	end

	def execute_pick_zone
		picked_zone = @data[:zone]
		duel.instance_eval do
			@last_picked_zone = picked_zone
		end
	end
end

