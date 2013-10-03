class Timing
	create :phase_draw do
		@phase = :draw
	end

	create :phase_standby do
		@phase = :standby
	end

	create :phase_main1 do
		@phase = :main1
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
