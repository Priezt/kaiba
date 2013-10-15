class Timing
	create :after_timing do
		self.timing_hooks.each do |timing_proc|
			timing_proc.call
		end
	end

	create :prepare_game do
		@first_player = players.values.sort_by{|p| p.to_s}.first
		@turn_count = 0
		@players.each_value do |p|
			p.put_deck
			p.shuffle_deck
			p.regenerate_life_point
			p.draw_card 5
		end
		goto :start_game
	end

	create :dump_game do
		puts self.dump
	end

	create :start_game do
		@turn_count = 1
		goto :enter_turn
	end

	create :enter_turn do
		@turn_count += 1
		self.switch_player
		tp.normal_summon_allowed_count = 1
		op.normal_summon_allowed_count = 0
		goto :enter_phase_draw
	end

	create :test_pass_args do
		goto :test_pass_args_2, :a => 1, :b => 2
	end

	create :test_pass_args_2 do
		p @td
		goto :end_pass_args, :a => 3, :b => 4
	end

	create :end_pass_args do
		p @td
	end

	create :quit do
		clear_timing_stack
	end

	create_raw :test_create_timing do
		enter do
			puts "Enter Timing"
		end

		leave do
			puts "Leave Timing"
		end
	end

	create :draw_card do
		log "tp.draw_card"
		tp.draw_card
	end

	create :totally_free do
		commands = self.get_all_commands
		goto :choose_command, :commands => commands, :priority_player => @td[:priority_player]
	end

	create :choose_command do
		commands = @td[:commands]
		if commands.count == 0
			raise Exception.new "impossible: no commands to be chosen"
		end
		log "[#{commands.map do |c|
			c.to_s
		end.join ", "}]"
		priority_player_force_commands = select_all_force_commands commands, @td[:priority_player]
		if priority_player_force_commands.count > 0
			command = choose_one_command priority_player_force_commands
			command.execute
			next
		end
		other_player_force_commands = select_all_force_commands commands, @td[:priority_player].other_player
		if other_player_force_commands.count > 0
			command = choose_one_command other_player_force_commands
			command.execute
			next
		end
		priority_player_optional_commands = select_all_optional_commands commands, @td[:priority_player]
		if priority_player_optional_commands.count > 0
			command = choose_one_command priority_player_optional_commands
			command.send :execute
			next
		end
		other_player_optional_commands = select_all_optional_commands commands, @td[:priority_player].other_player
		if other_player_optional_commands.count > 0
			command = choose_one_command other_player_optional_commands
			command.execute
			next
		end
		raise Exception.new "impossible: no force/optional commands chosen"
	end
end
require './phase'
