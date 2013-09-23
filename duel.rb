require 'tools'

class Duel
	bucket :players

	def initialize
		players << "Kaiba"
		players << "Yugi"
	end
end
