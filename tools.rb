class String
	def camel
		self.split("_").map{|s| s.capitalize}.join ""
	end
end

module NameToString
	def to_s
		@name
	end
end

module ActLikeString
	def initialize(name, &block)
		@name = name
		if block then self.instance_eval &block end
	end

	def to_s
		@name
	end
end

def class_with_name(classname, &block)
	Object.const_set classname, Class.new{
		include ActLikeString
	}
	if block
		Object.const_get(classname).class_eval &block
	end
end

class Bucket < Hash
	def <<(v)
		self[v.to_s] = v
	end

	def collect(&block)
		self.values.sort_by do |v|
			v.to_s
		end.collect &block
	end
end

class Class
	def bucket(sym)
		self.send :define_method, sym do
			r = self.instance_variable_get "@#{sym}"
			if not r
				self.instance_variable_set "@#{sym}", Bucket.new
			end
			self.instance_variable_get "@#{sym}"
		end
		self.send :define_method, "#{sym}=" do |v|
			self.instance_variable_set "@#{sym}", v
		end
	end
end
