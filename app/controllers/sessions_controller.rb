class SessionsController < Devise::SessionsController
	
	def create
		self.resource = warden.authenticate!( auth_options )
		set_flash_message( :notice, :signed_in ) if is_navigational_format?
		sign_in( resource_name, resource )

		record_app_event( 'login', on: @current_site, user: resource, content: 'logged in.' )
		respond_with resource, :location => after_sign_in_path_for( resource )
	end

end