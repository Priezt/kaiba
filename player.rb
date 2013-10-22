class Player
	include NameToString
	attr_accessor :duel
	attr_accessor :deck
	attr_accessor :life_point
	attr_accessor :side
	attr_accessor :normal_summon_allowed_count

	[
		'deck',
		'extra',
		'hand',
		'graveyard',
		'field',
		'remove',
	].each do |z|
		define_method "#{z}_zone" do
			side.zones[z]
		end
	end
	[
		'monster',
		'spell',
	].each do |z|
		define_method "#{z}_zones" do
			(1..5).to_a.map do |n|
				side.zones["#{z}:#{n}"]
			end
		end
	end

	def initialize(name)
		@name = name
		@life_point = 8000
	end

	def dump
		result = ""
		result += "#{@name}\n"
		#result += deck.dump
		result += side.dump
		result
	end

	def other_player
		@duel.players.each_value do |p|
			if p != self
				return p
			end
		end
	end

	def draw_card(count=1)
		count.times do
			side.zone["hand"].push side.zone["deck"].pop
		end
	end

	def put_deck
		{
			"deck" => "main_deck",
			"extra" => "extra_deck",
		}.each_pair do |k, v|
			side.zone[k].clear
			@deck.send(v).each do |c|
				card_instance = c.clone
				card_instance.duel = @duel
				card_instance.player = self
				side.zone[k].push card_instance
			end
		end
	end

	def shuffle_deck
		side.zone["deck"].shuffle
	end

	def regenerate_life_point
		@life_point = 8000
	end

	def get_all_card_commands
		commands = []
		all_my_cards.each do |c|
			commands += c.get_commands
		end
		commands
	end

	def all_my_cards
		all_cards = []
		all_cards += deck_zone.cards
		all_cards += extra_zone.cards
		all_cards += hand_zone.cards
		all_cards += field_zone.cards
		all_cards += graveyard_zone.cards
		all_cards += remove_zone.cards
		monster_zones.each do |z|
			all_cards += z.cards
		end
		spell_zones.each do |z|
			all_cards += z.cards
		end
		all_cards
	end

	include GetCommands

	def at_totally_free
		commands = []
		if @duel.turn_player == self
			commands << Command.new(self, :turn_end)
			if @duel.under :phase_main1
				commands << Command.new(self, :enter_battle)
			end
		end
		commands
	end

	def at_pick_summon_zone
	end
end

