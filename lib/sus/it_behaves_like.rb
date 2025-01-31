# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'context'

module Sus
	module ItBehavesLike
		extend Context
		
		attr_accessor :shared
		
		def self.build(parent, shared, unique: false)
			base = Class.new(parent)
			base.singleton_class.prepend(ItBehavesLike)
			base.children = Hash.new
			base.description = shared.name
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.class_exec(&shared.block)
			return base
		end
		
		def print(output)
			self.superclass.print(output)
			output.write(" it behaves like ", :describe, self.description, :reset)
		end
	end
	
	module Context
		def it_behaves_like(shared, **options)
			add ItBehavesLike.build(self, shared, **options)
		end
	end
end
