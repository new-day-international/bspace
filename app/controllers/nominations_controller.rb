class NominationsController < ApplicationController
	before_filter :authenticate_user!
	layout 'user_admin'
	

	def create
		@nomination = Nomination.new( params[:nomination] )
		@nomination.creator = @current_user

		if @nomination.save
			pop_flash "#{@nomination.name} Nominated!"
			redirect_to members_path
		else
			pop_flash "#{@nomination.name} could not be nominated", :error, @nomination
			render :new
		end

	end


	def new
		
	end

end