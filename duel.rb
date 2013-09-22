require 'tools'

strclass :Team

class Duel
	attr_reader :teams

	def initialize
		@teams = []
		@teams << Team.new("red")
		@teams << Team.new("green")
	end
end
