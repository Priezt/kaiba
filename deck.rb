class Deck
	attr_accessor :main_deck
	attr_accessor :extra_deck

	def initialize(&block)
		@main_deck ||= []
		@extra_deck ||= []
		if block
			self.instance_eval &block
		end
	end

	def dump
		"Main: #{
			@main_deck.collect do |c|
				c.to_s
			end.join ", "
		}\nExtra: #{
			@extra_deck.collect do |c|
				c.to_s
			end.join ", "
		}\n"
	end
end

