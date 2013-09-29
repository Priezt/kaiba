require 'duel'

if ENV['DEBUG']
	Timing.debug = true
end

duel = Duel.new Player.new("Kaiba"), Player.new("Yugi")

task :default => [:test]

desc "Common Test"
task :test do
	puts d.dump
end

task :timing do
	duel.start
end
