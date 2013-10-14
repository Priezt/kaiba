class Card
	include GetCommands
end

class SpellCard < Card
end

class TrapCard < Card
end

class MonsterCard < Card
	add_prop :level
	add_prop :attack
	add_prop :defend

	def at_totally_free
		return unless @duel.under :phase_main
		return unless @player.normal_summon_allowed_count > 0
		return unless @player == duel.td[:priority_player]
		return unless self.level <= 4
		return unless @zone.to_s == "hand"
		[Command.new(@player, :summon, :card => self, :optional => true)]
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
