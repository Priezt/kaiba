require 'tools'

class Player
	include NameToString
	attr_accessor :deck

	def initialize(name)
		@name = name
	end
end

class Timing; end
class << Timing
	def create(classname, &block)
		self.const_set classname.to_s.capitalize, Class.new{ }
		if block
			(self.const_get classname.to_s.capitalize).class_eval &block
		end
	end
end
class Timing
	create :free
end


class Side
	bucket :zones
	attr_accessor :player

	def initialize(p)
		self.player = p
		zones << Zone.new("deck")
		zones << Zone.new("extra")
		zones << Zone.new("hand")
		zones << Zone.new("field")
		zones << Zone.new("graveyard")
		zones << Zone.new("remove")
		(1..5).each do |n|
			zones << Zone.new("monster:#{n}")
			zones << Zone.new("spell:#{n}")
		end
	end

	def dump
		"#{player}: " + (zones.collect do |z|
			z.dump
		end.join " ")
	end
end

class Board
	bucket :sides

	def add_side(p)
		self.sides << Side.new(p)
	end

	def dump
		sides.collect do |s|
			s.dump + "\n"
		end.join ""
	end
end

class Zone
	include NameToString
	attr_accessor :cards

	def initialize(name)
		@name = name
		self.cards ||= []
	end

	def dump
		"#{@name}(#{self.cards.count})"
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
	attr_accessor :timing
	attr_accessor :turn_player
	attr_accessor :phase

	def initialize(p1, p2)
		self.players << p1
		self.players << p2
		self.board = Board.new
		self.board.add_side p1
		self.board.add_side p2
		self.turn_player = p1
		self.phase = :game_start
	end

	def dump
		result = ""
		result += self.board.dump
		result
	end
end
