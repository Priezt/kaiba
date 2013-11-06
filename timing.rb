class Timing; end

class << Timing
	attr_accessor :enter_proc
	attr_accessor :leave_proc
	attr_accessor :timing_option

	def create_p(classname, &block)
		create classname, :need_player_commands => true, &block
	end

	def create(classname, timing_option={}, &block)
		create_raw(classname, timing_option) do
			enter &block
		end
	end

	def create_raw(classname, timing_option={}, &block)
		self.const_set classname.to_s.camel, Class.new(Timing){
			self.timing_option = timing_option
		}
		if block
			(self.const_get classname.to_s.camel).class_eval &block
		end
	end

	def enter(&block)
		@enter_proc = block
	end

	def leave(&block)
		@leave_proc = block
	end
end

class Timing
	attr_accessor :timing_data

	def is(sym)
		self.class.to_s.sub(/.*\:/, "") == sym.to_s.camel
	end

	def to_s
		self.class.name.sub /.*:/, ''
	end
end

class Timing
	create_raw :test_create_timing do
		enter do
			puts "Enter Timing"
		end

		leave do
			puts "Leave Timing"
		end
	end

	create :test_pass_args do
		goto :test_pass_args_2, :a => 1, :b => 2
	end

	create :test_pass_args_2 do
		p @td
		goto :end_pass_args, :a => 3, :b => 4
	end

	create :end_pass_args do
		p @td
	end

	# this one is special, it should not be invoke by #goto
	create :after_timing do
		self.timing_hooks.each do |timing_proc|
			timing_proc.call
		end
	end

	create :quit do
		clear_timing_stack
	end

	create :prepare_game do
		@first_player = players.values.sort_by{|p| p.to_s}.first
		@turn_count = 0
		@players.each_value do |p|
			p.put_deck
			p.shuffle_deck
			p.regenerate_life_point
			p.draw_card 5
		end
		goto :start_game
	end

	create :dump_game do
		puts self.dump
	end

	create :start_game do
		@turn_count = 1
		goto :enter_turn
	end

	create :enter_phase do
		@priority_player = tp
	end

	create :enter_turn do
		@turn_count += 1
		self.switch_player
		tp.normal_summon_allowed_count = 1
		op.normal_summon_allowed_count = 0
		goto :enter_phase_draw
	end

	create :draw_card do
		log "tp.draw_card"
		tp.draw_card
	end

	create_p :totally_free do
		if @last[:has_commands]
			repeat
		else
			raise "No commands for totally_free"
		end
	end

	create :choose_command do
		commands = @td[:commands]
		if commands.count == 0
			raise Exception.new "impossible: no commands to be chosen"
		end
		log "[#{commands.map do |c|
			c.to_s
		end.join ", "}]"
		priority_player_force_commands = commands.force_commands.commands_for_player @priority_player
		if priority_player_force_commands.count > 0
			command = choose_one_command priority_player_force_commands
			command.execute
			next
		end
		other_player_force_commands = commands.force_commands.commands_for_player @priority_player.opponent
		if other_player_force_commands.count > 0
			command = choose_one_command other_player_force_commands
			command.execute
			next
		end
		priority_player_optional_commands = commands.optional_commands.commands_for_player @priority_player
		if priority_player_optional_commands.count > 0
			command = choose_one_command priority_player_optional_commands
			command.execute
			next
		end
		raise "Impossible: only priority player optional commands choose available"
	end

	create :normal_summon_monster do
		queue [:pick_summon_zone, :player => @td[:card].player],
			:about_to_summon,
			[:summon, :card => @td[:card]]
	end

	create :summon do
		@td[:card].summon @last[:picked_zone]
	end

	create :advance_summon_monster do
		@last[:release_left] = @td[:card].release_cost
		@last[:summon_card] = @td[:card]
		log "need #{release_left} monsters to release"
		queue :pick_release, [:pick_summon_zone, :player => @td[:card].player], :about_to_summon
	end

	create :pick_release do
		@last[:release_left] -= @last[:release_value]
		if @last[:release_left] > 0
			goto :pick_release
		end
	end

	create_p :pick_summon_zone do
	end

	create :about_to_summon do
		log "about to summon at #{@last[:picked_zone]}"
	end

	create :summoned do
	end
end
require './phase'
