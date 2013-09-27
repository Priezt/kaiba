require 'duel'

task :default => [:test]

desc "Common Test"
task :test do
	d = Duel.new Player.new("Kaiba"), Player.new("Yugi")
	puts d.dump
end

task :timing do
	p Timing::Free.new
end
