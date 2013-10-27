class Card
	def self.inherited(base)
		ancstrs = base.ancestors.clone
		ancstrs.shift
		base.properties ||= []
		base.properties += ancstrs.find{|c| c.to_s =~ /Card$/}.properties
	end

	def is(&block)
		[self].only(&block).length > 0
	end

	def under(timing)
		@duel.under timing
	end
end

class << Card
	attr_accessor :properties

	def add_prop(sym)
		@properties ||= []
		@properties << sym
		define_method sym do |*args|
			if args.length == 0
				eval "@#{sym.to_s}"
			else
				eval "@#{sym.to_s} = args[0]"
			end
		end
		define_singleton_method sym do |*args|
			if args.length == 0
				eval "@#{sym.to_s}"
			else
				eval "@#{sym.to_s} = args[0]"
			end
		end
	end
end

class Card
	attr_accessor :duel
	attr_accessor :player
	attr_accessor :zone

	add_prop :name
	add_prop :text

	def self.[](card_name)
		eval("Card::#{card_name.to_s}").new
	end

	def initialize
		self.class.properties.each do |p|
			self.send p, (self.class.send p)
		end
		@face = :down
		@position = :vertical
	end

	def to_s
		@name
	end

	def clone
		Card[self.class.to_s.sub(/.*:/, "")]
	end

	def method_missing(method_name, *args, &block)
		self.class.send method_name, *args, &block
	end

	def optional(command_sym, args={})
		args[:card] = self
		args[:optional] = true
		Commands.new controller, command_sym, args
	end

	def force(command_sym, args={})
		args[:card] = self
		args[:force] = true
		Commands.new controller, command_sym, args
	end

	def controller
		self.zone.side.player
	end
end

class Card
	include GetCommands

	def in_zone(z)
		current_zone_name = @zone.to_s.sub /:.*/, ''
		zn = z.to_s
		if zn == current_zone_name
			true
		else
			false
		end
	end

	def same_side(c)
		self.zone.side == c.zone.side
	end

	def release_consume(target_card)
		target_card.release_value self
	end

	def release_value(for_card)
		if same_side(for_card) and in_zone(:monster)
			1
		else
			0
		end
	end
end

class SpellCard < Card
end

class TrapCard < Card
end

class MonsterCard < Card
	add_prop :level
	add_prop :attack
	add_prop :defend

	def at_pick_release
		todo "release condition"
		return unless is{
			monster
		}
		[
			optional :release
		]
	end

	def at_totally_free
		todo "implement using new way: is and force/optional"
		return unless under(:phase_main) and @player.normal_summon_allowed_count > 0 and @player == duel.td[:priority_player] and is{ on :hand }
		if self.level <= 4
			[
				Command.new(@player, :summon, :card => self, :optional => true),
				Command.new(@player, :monster_set, :card => self, :optional => true),
			]
		elsif self.level > 4
			available_release_value = duel.all_cards.map{|c|
				self.release_consume c
			}.reduce(:+)
			if available_release_value >= summon_release_cost
				[
					Command.new(@player, :advance_summon, :card => self, :optional => true),
					Command.new(@player, :advance_monster_set, :card => self, :optional => true),
				]
			end
		end
	end

	def summon_release_cost
		if [1, 2, 3, 4].include? level
			0
		elsif [5, 6].include? level
			1
		else
			2
		end
	end
end

class NormalSpellCard < SpellCard
end

class QuickSpellCard < SpellCard
end

class RitualSpellCard < SpellCard
end

class ContinuousSpellCard < SpellCard
end

class FieldSpellCard < SpellCard
end

class EquipSpellCard < SpellCard
end

class NormalTrapCard < TrapCard
end

class ContinuousTrapCard < TrapCard
end

class CounterTrapCard < TrapCard
end

class NormalMonsterCard < MonsterCard
end

class EffectMonsterCard < MonsterCard
end

class RitualMonsterCard < MonsterCard
end

class FusionMonsterCard < MonsterCard
end

class SynchronMonsterCard < MonsterCard
end

class XyzMonsterCard < MonsterCard
end
