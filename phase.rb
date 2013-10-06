class Timing
	create :phase_draw do
		@phase = :draw
		stack :before_draw, :draw_card, :after_draw, :phase_standby
	end

	create :phase_standby do
		@phase = :standby
		goto :phase_main1
	end

	create :phase_main1 do
		@phase = :main1
		goto :free_main_phase_1
	end

	create :phase_battle do
		@phase = :battle
	end

	create :phase_main2 do
		@phase = :main2
	end

	create :phase_end do
		@phase = :end
	end
end
