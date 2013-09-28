require 'tools'

class Player
	include NameToString
	attr_accessor :deck

	def initialize(name)
		@name = name
	end
end

class Timing
end
class << Timing
	def create(classname, &block)
		self.const_set classname.to_s.camel, Class.new(Timing){ }
		if block
			(self.const_get classname.to_s.camel).class_eval &block
		end
	end
end
class Timing
	create :any_time
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
	attr_reader :timing
	attr_accessor :turn_player
	attr_accessor :phase
	attr_accessor :turn_count

	def timing=(new_timing)
		@timing = eval "Timing::#{new_timing.to_s.camel}.new"
	end

	def initialize(p1, p2)
		self.players << p1
		self.players << p2
		self.board = Board.new
		self.board.add_side p1
		self.board.add_side p2
		self.turn_player = p1
	end

	def dump
		result = ""
		result += self.board.dump
		result
	end

	def change_phase(new_phase)
		self.phase = new_phase
	end

	def prepare(first_player=nil)
		fist_player = self.players.values.sort{|p| p.to_s}.first
		self.turn_count = 0
		self.phase = :start_game
	end

	def start
		self.turn_count = 1
		self.change_phase :draw
	end
end
