class SpacesController < ApplicationController
	before_filter :authenticate_user!
	layout 'user_admin'
end