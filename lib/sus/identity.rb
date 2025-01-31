# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

module Sus
	class Identity
		def self.nested(parent, name, location = nil, **options)
			location ||= caller_locations(3...4).first
			
			self.new(location.path, name, location.lineno, parent, **options)
		end
		
		# @parameter unique [Boolean | Symbol] Whether this identity is unique or needs a unique key/line number suffix.
		def initialize(path, name = nil, line = nil, parent = nil, unique: true)
			@path = path
			@name = name
			@line = line
			@parent = parent
			@unique = unique
			
			@key = nil
		end
		
		attr :path
		attr :name
		attr :line
		attr :parent
		attr :unique
		
		def to_s
			self.key
		end
		
		def inspect
			"\#<#{self.class} #{self.to_s}>"
		end
		
		def match?(other)
			if path = other.path
				return false unless path === @path
			end
			
			if name = other.name
				return false unless name === @name
			end
			
			if line = other.line
				return false unless line === @line
			end
		end
		
		def each(&block)
			@parent&.each(&block)
			
			yield self
		end
		
		def key
			unless @key
				key = Array.new
				
				# For a specific leaf node, the last part is not unique, i.e. it must be identified explicitly.
				append_unique_key(key, @unique == true ? false : @unique)
				
				@key = key.join(':')
			end
			
			return @key
		end
		
		protected
		
		def append_unique_key(key, unique = @unique)
			if @parent
				@parent.append_unique_key(key)
			else
				key << @path
			end
			
			if unique == true
				# No key is needed because this identity is unique.
			else
				if unique
					key << unique
				elsif @line
					key << @line
				end
			end
		end
	end
end
