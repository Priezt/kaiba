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

	def execute
		log "execute command: #{self}"
	end

	include DuelLog
end

