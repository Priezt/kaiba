class Player
	def draw_card
		side.zone["hand"].push side.zone["deck"].pop
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
end
