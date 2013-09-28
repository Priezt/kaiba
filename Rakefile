require 'duel'

duel = Duel.new Player.new("Kaiba"), Player.new("Yugi")

task :default => [:test]

desc "Common Test"
task :test do
	puts d.dump
end

task :timing do
	duel.timing = :any_time
	p duel.timing
end
