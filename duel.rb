require 'tools'

class Player
	include NameToString
	attr_accessor :deck

	def initialize(name)
		@name = name
	end
end

class Side
	bucket :zones
	def initialize
		zones << Zone.new("deck")
		zones << Zone.new("extra")
		zones << Zone.new("hand")
		zones << Zone.new("remove")
		zones << Zone.new("field")
		zones << Zone.new("graveyard")
		(1..5).each do |n|
			zones << Zone.new("monster:#{n}")
			zones << Zone.new("spell:#{n}")
		end
	end
end

class Board
	bucket :sides
	def initialize
		self.sides << Side.new
		self.sides << Side.new
	end
end

class Zone
	include NameToString
	attr_accessor :cards

	def initialize(name)
		@name = name
		cards ||= []
	end
end

class Card
	include NameToString

	def initialize(name)
		@face = :down
		@position = :vertical
		@name = name
	end
end

class Duel
	bucket :players
	attr_accessor :board

	def initialize
		self.board = Board.new
	end
end
