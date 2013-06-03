class Space < ActiveRecord::Base
	attr_protected :none

	acts_as_nested_set

	
end