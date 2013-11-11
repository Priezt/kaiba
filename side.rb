class Side
	bucket :zones
	alias zone zones
	attr_accessor :player

	def initialize(p)
		self.player = p
		p.side = self
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
		zones.each_value do |z|
			z.side = self
		end
	end

	def dump
		"#{player}: " + (zones.collect do |z|
			z.dump
		end.join " ")
	end

	def snapshot
		{
			:player => player.to_s,
			:zones => todo("snapshot for zones"),
		}
	end
end
