class Board
	bucket :sides

	def add_side(p)
		self.sides << Side.new(p)
	end

	def dump
		sides.collect do |s|
			s.dump + "\n"
		end.join ""
	end

	def snapshot
		{
			:sides => sides.each_value.map(&:snapshot)
		}
	end
end
