class UsersController < ApplicationController
	before_filter :authenticate_user!
	
	def home
		render layout: 'user_admin'
	end

	def index
		@members = User.all
		render layout: 'user_admin'
	end
	
end