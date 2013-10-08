require './duel'
require './duel_console'

if ENV['DEBUG']
	Timing.debug = true
end

duel = Duel.new Player.new("Kaiba"), Player.new("Yugi")
["Kaiba", "Yugi"].each do |p|
	duel.players[p].deck = Deck.new do
		20.times do
			@main_deck << Card[:GeneticWolf]
		end
		10.times do
			@main_deck << Card[:GeneticWolfV]
		end
		10.times do
			@main_deck << Card[:Fusion]
		end
	end
end

task :default => [:test]

desc "Common Test"
task :test do
	duel.start
end

task :timing do
	duel.add_timing_hook proc{
		puts "hook:#{duel}"
	}
	duel.start
end

task :duel do
	p duel
end

task :card do
	p Card.properties
	p MonsterCard.properties
	p NormalMonsterCard.properties
	p Card::GeneticWolf.properties
	p Card::GeneticWolf.new.attack
end

task :player do
	duel.players["Kaiba"].put_deck
	duel.players["Kaiba"].shuffle_deck
	duel.players["Kaiba"].draw_card
	puts duel.players["Kaiba"].dump
end

desc "Duel Console"
task :duel_console do
	dc = DuelConsole.new duel
	dc.start
end
