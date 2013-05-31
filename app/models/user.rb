class User < ActiveRecord::Base #SwellUsers::User
	# Setup accessible (or protected) attributes for your model
	attr_protected :slug, :encrypted_password, :reset_password_token, :reset_password_token_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at, :authentication_token
	attr_accessor	:login

	### FILTERS		--------------------------------------------
	before_save 		:prep_name
	after_validation 	:geocode          # auto-fetch coordinates to populate latitude and longitude

	### VALIDATIONS	---------------------------------------------
	validates_uniqueness_of		:name, case_sensitive: false, allow_blank: true, if: :name_changed?
	validates_uniqueness_of		:email, case_sensitive: false, if: :email_changed?
	validates_format_of			:email, with: Devise.email_regexp, if: :email_changed?

	validates_confirmation_of	:password, if: :encrypted_password_changed?
	validates_length_of			:password, within: Devise.password_length, allow_blank: true, if: :encrypted_password_changed?

	### RELATIONSHIPS   	--------------------------------------
	has_many 	:user_roles, dependent: :destroy
	has_many	:roles, through: :user_roles
	

	### Plugins  	---------------------------------------------
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable,
	# :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :omniauthable, :registerable, :recoverable, :rememberable, :trackable, authentication_keys: [ :login ]

	extend FriendlyId
	  	friendly_id :name, use: :slugged

	geocoded_by	:ip

	### Class Methods   	--------------------------------------
	# over-riding Deivse method to allow login via name or email
	def self.find_first_by_auth_conditions( warden_conditions )
		conditions = warden_conditions.dup
		if login = conditions.delete( :login )
			where( conditions ).where( ["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }] ).first
		else
			where( conditions ).first
		end
    end

	def self.new_from_fb( auth )
		user = User.where( email: auth['extra']['raw_info'].email ).first || 
					User.new( email: auth['extra']['raw_info'].email, name: auth['extra']['raw_info'].username )

		user.attributes.merge!( {
				avatar: auth['info']['image'],
				first_name: auth['info']['first_name'], 
				last_name: auth['info']['last_name'], 
				gender: auth['extra']['raw_info'].gender 
				}
			)
		user.oauth_credentials.build( 
				provider: auth['provider'], 
				uid: auth['uid'], 
				token: auth['credentials'].token, 
				secret: auth['credentials'].secret
			)
		return user
	end

	def self.new_from_twitter( auth )
		return User.new( 
				name: auth['info']['nickname'] )
	end


	### Instance Methods  	--------------------------------------

	def add_role( role )
		role_to_add = Role.where( name: role.to_s ).first_or_create
		self.roles << role_to_add
	end

	def avatar_tag( opts={} )
		return self.gravatar_tag( opts ) if self.avatar.blank?

		tag = "<img src="
		tag += "'" + self.avatar + "' "
		for key, value in opts do
			tag += key.to_s + "='" + value.to_s + "' "
		end
		tag += "/>"
		return tag.html_safe
		
	end

	def fb_graph
		return false unless fb_credential = self.oauth_credentials.where( provider: 'facebook' ).last
		@graph ||= Koala::Facebook::API.new( fb_credential.token )
		block_given? ? yield( @graph ) : @graph
	end

	def full_name
		"#{self.first_name} #{self.last_name}"
	end

	def full_name=( name )
		name_array = name.split( / / )
		self.first_name = name_array.shift
		self.last_name = name_array.join( ' ' )
	end

	def gravatar_tag( opts={} )
		default = opts[:default] || 'identicon'
		gravatar = "http://gravatar.com/avatar/" + Digest::MD5.hexdigest( self.email ) + "?d=#{default}"
		tag = "<img src="
		tag += "'" + gravatar + "' "
		for key, value in opts do
			tag += key.to_s + "='" + value.to_s + "' "
		end
		tag += "/>"
		return tag.html_safe
	end

	def has_role?( role )
		return !!self.roles.find_by_name( role.to_s )
	end

	def linked_full_name
		# todo -- add points, trust. If points < x no link if points > y remove rel=nofollow
		url = self.website_url || "users/#{self.slug}"
		return "<a href='#{url}' rel='nofollow'>#{self.full_name}</a>"
	end

	def provider
		Provider.where( user_id: self.id ).last
	end

	def ref_code
		self.name || self.id
	end

	def to_s
		str = self.name || "#{self.first_name} #{self.last_name}"

		str = 'Guest' if str.blank?
		return str
	end

	def website
		self.website_url.present? ? self.website_url : "/users/#{self.slug}" 
	end

	private

		def email_reachable?
			return if self.email.blank? || self.is_guest?

			begin
				domain = self.email.match(/\@(.+)/)[1]
			rescue
				errors.add( :email, "#{self.email} is not a valid email" )
				return false
			end

			Resolv::DNS.open do |dns|
				@mx = dns.getresources( domain, Resolv::DNS::Resource::IN::MX )
			end

			if @mx.size > 0
				return true
			else
				errors.add( :email, "#{domain} is not a valid domain" )
				return false
			end
		end

		def email_well_formed?
			return if self.email.blank? || self.is_guest?

			if self.email =~ /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
				return true
			else
				errors.add( :email, "is not a properly formed address" )
				return false
			end

		end

		def prep_name
			self.first_name ||= self.email.split( /@/ ).first
		end


end