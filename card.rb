class Card
	class GeneticWolf < NormalMonsterCard
		name "Genetic Wolf"
		level 4
		attack 2000
		defend 100
	end

	class GeneticWolfV < NormalMonsterCard
		name "Genetic Wolf V"
		level 6
		attack 3000
		defend 500
	end

	class Fusion < NormalSpellCard
		name "Fusion"

		def can_activate_now?
			true
		end
	end
end
