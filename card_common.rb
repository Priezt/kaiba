class Card
	def can_normal_summon?
		@level and @level <= 4
	end

	def can_activate_now?
		false
	end

	def get_commands
		[]
	end
end

class SpellCard < Card
end

class MonsterCard < Card
	add_prop :level
	add_prop :attack
	add_prop :defend
end

class NormalSpellCard < SpellCard
end

class NormalMonsterCard < MonsterCard
end
