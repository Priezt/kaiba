require 'duel'
require 'irb'
require 'irb/completion'

if ENV['DEBUG']
	Timing.debug = true
end

duel = Duel.new Player.new("Kaiba"), Player.new("Yugi")
duel.players["Kaiba"].deck = Deck.new do
	40.times do
		@main_deck << Card[:GeneticWolf]
	end
end

task :default => [:test]

desc "Common Test"
task :test do
	puts d.dump
end

task :timing do
	duel.start :test_create_timing
end

task :duel do
	p duel
end

task :card do
	p Card::GeneticWolf.new
	p Card::GeneticWolf.attack
	p Card['GeneticWolf'].attack
end

task :player do
	puts duel.players["Kaiba"].dump
end
