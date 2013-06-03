class AdminController < ApplicationController
	layout 'admin'

	def app_events
		authorize! :admin, AppEvent
		@events = AppEvent.order( 'created_at desc' ).page( params[:page] )
	end

	def users
		authorize! :admin, User
		@users = User.order( 'created_at desc' )
	end

	def index
		authorize! :admin, AppEvent
	end


end