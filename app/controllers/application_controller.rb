class ApplicationController < ActionController::Base
	protect_from_forgery
	layout 'application'

	http_basic_authenticate_with :name => "gameb", :password => "playa"

	before_filter :initialize_session



	rescue_from CanCan::AccessDenied do |exception|
    	flash[:error] = exception.message
    	redirect_to "/"
  	end

  	def after_sign_in_path_for( resource )
 		if resource.has_role?( :admin )
 			return '/admin'
 		elsif resource.provider.present?
 			return provider_home_path
 		else
 			return user_home_path
 		end
	end

  	# over-ride CanCan's method to use @current_user
	def current_ability
		return Ability.new( User.new ) if @current_user.nil?
		@current_ability ||= Ability.new( @current_user )
	end

	def pop_flash( message, code=:success, *objs )
		if flash[code].blank?
			flash[code] = "<p>#{message}</p>"
  		else
  			flash[code] += "<p>#{message}</p>"
  		end
  		objs.each do |obj|
  			obj.errors.each do |error|
	  			flash[code] += "<p>#{error.to_s}: #{obj.errors[error].join(';')}</p>"
			end
		end
	end

	def set_metatags( args={} )
		# sets page metadata like page title and description
		# each controller uses this method to set it with local data (e.g. a specific blog or forum title)
		# these get put into instance variables that the _meta partial reads into the layout
		@metatags = args
		@metatags[:title] ||= request.domain
		@metatags[:description] = args[:description][0..200] unless args[:description].blank?
		@metatags[:description] = @current_space.present? ? @current_space.description : nil
		
	end


	def record_app_event( event='view', args={} )
		# this method can be called by any controller to log a specific event
		# such as a purchase, comment, newsletter signup, etc.
		event = event.to_s
		args[:request] ||= request
		args[:space] ||= @current_space
		args[:user] ||= @current_user
		args[:participant_id] ||= cookies[:pid]

		return AppEvent.record( event, args )

	end


	private

		def cookie_referrer
			ref_user = User.where( name: params[:ref] ).first || User.where( id: params[:ref] ).first
			ref_id = ref_user.try( :id )
			# referrer cookie is always user.id
			cookies[:referrer] = { :value => ref_id, :expires => 30.days.from_now } if ref_user.present?
			return ref_id
		end
		

		def initialize_session
			@current_space = initialize_space
			@current_user = initialize_user
			ref_id = cookie_referrer
			record_app_event( :visit, on: @current_space, rate: 16.hours, content: "visited #{@current_space}", ref: ref_id )
			
			set_metatags
		end


		def initialize_space
			space = Space.last
			return space
		end

		def initialize_user
			# if using Devise
			return current_user
		end

end
