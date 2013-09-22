module ActLikeString
	def initialize(name)
		@name = name
	end

	def to_s
		@name
	end
end

def strclass(classname)
	Object.const_set classname, Class.new{
		include ActLikeString
	}
end
