require 'duel'
require 'irb'
require 'irb/completion'

if ENV['DEBUG']
	Timing.debug = true
end

duel = Duel.new Player.new("Kaiba"), Player.new("Yugi")
["Kaiba", "Yugi"].each do |p|
	duel.players[p].deck = Deck.new do
		20.times do
			@main_deck << Card[:GeneticWolf]
		end
		20.times do
			@main_deck << Card[:GeneticWolfV]
		end
	end
end

task :default => [:test]

desc "Common Test"
task :test do
	duel.start
end

task :timing do
	Timing.add_timing_hook proc{ |d|
		puts "hook:#{d}"
	}
	duel.start
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
	duel.players["Kaiba"].put_deck
	duel.players["Kaiba"].shuffle_deck
	duel.players["Kaiba"].draw_card
	puts duel.players["Kaiba"].dump
end
