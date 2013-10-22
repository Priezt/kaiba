class CardFilter
	def initialize(cards)
		@cards = cards
	end

	def self.card_type(sym)
		card_class = eval("::" + sym.to_s.camel + "Card")
		define_method sym do
			@cards = @cards.select do |c|
				c.class <= card_class
			end
		end
	end

	card_type :monster
	card_type :spell
	card_type :trap
	card_type :normal_monster
	card_type :effect_monster
	card_type :synchron_monster
	card_type :xyz_monster
	card_type :fusion_monster
	card_type :ritual_monster
	card_type :normal_spell
	card_type :quick_spell
	card_type :ritual_spell
	card_type :continuous_spell
	card_type :field_spell
	card_type :equip_spell
	card_type :normal_trap
	card_type :continuous_trap
	card_type :counter_trap

	def on(place)
		@cards = @cards.select do |c|
			c.in_zone place
		end
	end

	def result
		@cards
	end
end

class Array
	def only(&block)
		card_filter = CardFilter.new self
		card_filter.instance_eval &block
		card_filter.result
	end
end
