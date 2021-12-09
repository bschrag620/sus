
require_relative 'context'

module Sus
	module With
		extend Context
		
		attr_accessor :subject
		attr_accessor :variables
		
		def self.build(parent, subject, variables, unique: true, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(With)
			base.children = Hash.new
			base.subject = subject
			base.description = subject
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.variables = variables
			
			variables.each do |key, value|
				base.define_method(key, ->{value})
			end
			
			if block_given?
				base.class_exec(&block)
			end
			
			return base
		end
		
		def print(output)
			self.superclass.print(output)
			output.write(
				" with ", :with, self.description, :reset,
				# " ", :variables, self.variables.inspect
			)
		end
	end
	
	module Context
		def with(subject, **variables, &block)
			add With.build(self, subject, variables, &block)
		end
	end
end
