class Player
	def draw_card(count=1)
		count.times do
			side.zone["hand"].push side.zone["deck"].pop
		end
	end

	def put_deck
		side.zone["deck"].clear
		@deck.main_deck.each do |c|
			side.zone["deck"].push c.clone
		end
		side.zone["extra"].clear
		@deck.extra_deck.each do |c|
			side.zone["extra"].push c.clone
		end
	end

	def shuffle_deck
		side.zone["deck"].shuffle
	end

	def regenerate_life_point
		@life_point = 8000
	end

	def normal_summon_commands
		if normal_summon_allowed_count <= 0
			return []
		end
		tp.hand_zone.cards.select do |c|
			c.can_normal_summon?
		end
	end
end

