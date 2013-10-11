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
		goto :choose_command, :commands => commands
	end

	create :choose_command do
		commands = @td[:commands]
		log "[#{commands.map do |c|
			c.to_s
		end.join ", "}]"
		goto :quit
	end
end
require './phase'
