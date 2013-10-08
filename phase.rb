class Timing
	create :enter_phase_draw do
		stack :before_draw,
			:draw_card,
			:after_draw,
			:phase_draw,
			:enter_phase_standby
	end

	create :enter_phase_standby do
		stack :phase_standby,
			:enter_phase_main1
	end

	create :enter_phase_main1 do
		stack :phase_main1,
			:phase_main,
			:enter_phase_battle
		all_available_commands = []
		all_available_commands << Command.new(tp, :turn_end)
		all_available_commands << Command.new(tp, :enter_battle)
		all_available_commands += tp.get_all_card_commands
		all_available_commands += op.get_all_card_commands
		log "[#{all_available_commands.map do |c|
			c.to_s
		end.join ", "}]"
		goto :quit
	end

	create :free_main_phase_1 do
		all_available_commands = @td[:all_available_commands]
		all_available_commands << Command.new(tp, :enter_battle)
		log "[#{all_available_commands.map do |c|
			c.to_s
		end.join ", "}]"
	end

	create :enter_phase_battle do
		stack :phase_battle,
			:enter_phase_main2
	end

	create :enter_phase_main2 do
		stack :phase_main2,
			:phase_main,
			:enter_phase_end
	end

	create :enter_phase_end do
		stack :phase_end,
			:enter_turn
	end
end
