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
		@phase = :draw
		goto :enter_turn
	end

	create :enter_turn do
		@turn_count += 1
		self.switch_player
		tp.normal_summon_allowed_count = 1
		goto :phase_draw
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

	create :free_main_phase_1 do
		all_available_commands = []
		log tp.monster_zones
		all_available_commands << Commands.new(tp, :enter_battle)
		all_available_commands << Commands.new(tp, :turn_end)
		all_available_commands << tp.normal_summon_commands
	end
end
require 'phase'
