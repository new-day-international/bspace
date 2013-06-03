class RegistrationsController < Devise::RegistrationsController

	def create
		email = params[:user][:email]
		# todo -- check validity of email param?

		# can only register if nomination exists with status=='accepted'

		user = User.where( email: email ).joins( :nomination ).where( nominations: {  status: 'accepted' } ).first 


		if user.nil?
			# this email is already registered for this site
			pop_flash "#{email} is not yet eligible for membership.", :error
			redirect_to :back
			return false
		end

		if user.encrypted_password.present?
			# this email is already registered for this site
			pop_flash "#{email} is already registered.", :error
			redirect_to :back
			return false
		end

		user.password = params[:user][:password]
		user.password_confirmation = params[:user][:password_confirmation]

		if user.save
			record_app_event( 'registration', on: @current_site, user: user, content: 'registered.' )
			set_flash_message :notice, :signed_up if is_navigational_format?
        	sign_up( :user, user )
        	respond_with user, location: after_sign_up_path_for( user )
		else
			pop_flash "Could not register user.", :error, user
			render :new
			return false
		end

	end

end