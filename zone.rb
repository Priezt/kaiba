class Zone
	include NameToString
	attr_accessor :cards
	attr_accessor :side

	def initialize(name)
		@name = name
		self.cards ||= []
	end

	def dump
		"#{@name}(#{self.cards.count})"
	end

	def pop
		c = self.cards.pop
		c.zone = nil
		c
	end

	def push(c)
		self.cards.push c
		c.zone = self
	end

	def clear
		self.cards = []
	end

	def shuffle
		@cards = @cards.sort_by do |c|
			rand
		end
	end

	def available?
		cards.length == 0
	end

	alias empty? available?
end
