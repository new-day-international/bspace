class Ability

	# Used by CanCan to define abilities and access priveledges

	include CanCan::Ability

	def initialize( user )
		if user.has_role?( :admin )
			can :manage, :all
		end
	end
end