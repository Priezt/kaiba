require "curses"

class DuelConsole
	include Curses

	class Point
		attr_accessor :row, :col

		def initialize(_row, _col)
			@row = _row
			@col = _col
		end
	end
	
	def initialize(d)
		@duel = d
		@duel.add_timing_hook proc{
			self.draw_duel
		}
		@last_key = nil
		@player_side_map = {}
		side = :left
		@duel.players.each_key do |k|
			@player_side_map[k] = side
			if side == :left
				side = :right
			else
				side = :left
			end
		end
		init_curses
	end

	def init_curses
		init_screen
		start_color
		init_pair 1, COLOR_GREEN, COLOR_BLACK
		attron color_pair(1)
		bkgd color_pair(1)
	end

	def start
		@duel.start
	end

	def draw_duel
		if @duel.end?
			close_screen
		else
			@row_count = lines
			@col_count = cols
			@center_row = @row_count / 2
			@center_col = @col_count / 2
			@zone_width = @center_col / 3
			@zone_height = (@row_count - 2) / 7
			clear
			draw_timing
			draw_center_line
			draw_last_key
			draw_zones
			draw_x
			refresh
			process_input_key getch
		end
	end

	def get_point_by_row_col(side, row_num, col_num)
		_col = row_num * @zone_width
		_row = col_num * @zone_height
		if side == :left
			Point.new 1 + _row, @center_col - @zone_width - _col
		else
			Point.new 1 + 6 * @zone_height - _row, @center_col + 1 + _col
		end
	end

	def draw_zones
		@duel.players.each_value do |p|
			[
				'deck',
				'extra',
				'field',
				'graveyard',
				'remove',
				'hand',
				'monster:1',
				'monster:2',
				'monster:3',
				'monster:4',
				'monster:5',
				'spell:1',
				'spell:2',
				'spell:3',
				'spell:4',
				'spell:5',
			].each do |z|
				pt = get_point_by_zone_name @player_side_map[p.to_s], z
				screen_point = get_point_by_row_col @player_side_map[p.to_s], pt.row, pt.col
				draw_one_zone screen_point.row, screen_point.col, z, p
			end
		end
	end

	def draw_one_zone(row, col, zone_name, player)
		str row, col, "#{zone_name.upcase}(#{player.side.zone[zone_name].cards.length})"
	end

	def get_point_by_zone_name(side, zn)
		case zn
		when 'hand'
			if side == :left
				Point.new 2, 0
			else
				Point.new 2, 5
			end
		when 'monster:1'
			Point.new 0, 1
		when 'monster:2'
			Point.new 0, 2
		when 'monster:3'
			Point.new 0, 3
		when 'monster:4'
			Point.new 0, 4
		when 'monster:5'
			Point.new 0, 5
		when 'spell:1'
			Point.new 1, 1
		when 'spell:2'
			Point.new 1, 2
		when 'spell:3'
			Point.new 1, 3
		when 'spell:4'
			Point.new 1, 4
		when 'spell:5'
			Point.new 1, 5
		when 'deck'
			Point.new 1, 6
		when 'extra'
			Point.new 1, 0
		when 'field'
			Point.new 0, 0
		when 'graveyard'
			Point.new 0, 6
		when 'remove'
			Point.new 2, 6
		else
			raise Exception.new("no such zone name: #{zn}")
		end
	end

	def draw_last_key
		if @last_key
			str @row_count - 1, 0, @last_key.chr
		end
	end

	def process_input_key(k)
		@last_key = k
		case k.chr
		when 'q'
			duel.goto :quit
		else
		end
	end

	def draw_center_line
		(1..(@row_count - 2)).each do |r|
			str r, @center_col, "|"
		end
	end

	def str(r, c, _str)
		setpos r, c
		addstr _str
	end

	def draw_timing
		str 0, 0, @duel.instance_eval{@current_timing}.class.to_s
	end

	def draw_x
		str @row_count - 1, @col_count - 1, "X"
	end
end
