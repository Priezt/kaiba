class InteractiveConsole
	def initialize(d)
		@duel = d
		@duel.add_timing_hook proc{
		}
		@duel.add_choose_hook proc{|commands|
			self.choose_one_command commands
		}
	end

	def list(commands)
		(1..commands.count).each do |i|
			puts "#{i}: #{commands[i-1]}"
		end
	end

	def choose_one_command(commands)
		list commands
		while true
			print "> "
			STDOUT.flush
			cmd = STDIN.readline.chomp
			if cmd =~ /^(\d+)$/
				idx = cmd.to_i
				if idx > 0 and idx <= commands.count
					return commands[idx - 1]
				else
					puts "error: command index out of range"
				end
			elsif cmd =~ /^list$/
				list commands
			else
				begin
					puts eval cmd
				rescue
					puts "error:#{$!}"
				end
			end
		end
	end

	def start
		@duel.start
	end
end
