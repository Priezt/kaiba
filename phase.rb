class Timing
	create :enter_phase_draw do
		stack :enter_phase,
			:before_draw,
			:draw_card,
			:after_draw,
			:phase_draw,
			:enter_phase_standby
	end

	create :enter_phase_standby do
		stack :enter_phase,
			:phase_standby,
			:enter_phase_main1
	end

	create :enter_phase_main1 do
		stack :enter_phase,
			[:totally_free, {:priority_player => tp}],
			:phase_main1,
			:phase_main,
			:enter_phase_battle
	end

	create :enter_phase_battle do
		stack :enter_phase,
			:phase_battle,
			:enter_phase_main2
	end

	create :enter_phase_main2 do
		stack :enter_phase,
			:phase_main2,
			:phase_main,
			:enter_phase_end
	end

	create :enter_phase_end do
		stack :enter_phase,
			:phase_end,
			:enter_turn
	end
end
