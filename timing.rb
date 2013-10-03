class Timing
	create :prepare_game do
		@first_player = players.values.sort_by{|p| p.to_s}.first
		@turn_count = 0
		@players.each_value do |p|
			p.put_deck
			p.shuffle_deck
			p.regenerate_life_point
		end
		#goto :start_game
		goto :dump_game
	end

	create :dump_game do
		puts self.dump
	end

	create :start_game do
		@turn_count = 1
		@phase = :draw
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

	create_raw :test_create_timing do
		enter do
			puts "Enter Timing"
		end

		leave do
			puts "Leave Timing"
		end
	end
end
