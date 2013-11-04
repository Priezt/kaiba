class Duel
	attr_accessor :current_timing

	def under(timing_sym)
		([@current_timing] + @timing_stack).find do |t|
			t.class.to_s.sub(/.*\:/, '') == timing_sym.to_s.camel
		end
	end

	def end?
		@timing_stack ||= []
		@timing_stack.length == 0
	end

	def start(start_timing = :prepare_game)
		@last = {}
		self.push_timing start_timing
		while @timing_stack.length > 0
			self.run_timing
		end
		log "no timing left"
	end

	def set_timing(new_timing_symbol, args)
		self.clear_timing_stack
		self.push_timing new_timing_symbol, args
	end

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

	def clear_timing_stack
		@timing_stack = []
	end

	def push_timing_with_pass(new_timing_symbol, args={})
		args[:pass] = true
		push_timing(new_timing_symbol, args)
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

	alias stack push_multiple_timing
	alias queue push_multiple_timing

	alias goto push_timing
	alias pass push_timing_with_pass

	def run_timing
		@current_timing = @timing_stack.pop
		@td = @current_timing.timing_data
		log "enter #{@current_timing.class.to_s}"
		unless @td[:pass]
			pass @current_timing.class.to_s.sub(/.*:/, '').uncamel
			commands = query_all_commands @current_timing.instance_eval{self.class.timing_option}[:need_player_commands]
			if commands.length > 0
				@last[:has_commands] = true
				return
			else
				@last[:has_commands] = false
				@timing_stack.pop
			end
		end
		self.instance_eval &(@current_timing.class.enter_proc)
		after_timing = Timing::AfterTiming.new
		#after_timing.timing_data = @current_timing # I forget what is this for
		self.instance_eval &(after_timing.class.enter_proc)
	end

	def dump_timing_stack
		"[#{
			@timing_stack.map do |t|
				t.to_s
			end.join ", "
		}]"
	end

	def choose_command(commands)
		goto :choose_command, :commands => commands
	end
end
