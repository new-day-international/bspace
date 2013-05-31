class Media < ActiveRecord::Base
	attr_protected :user_id, :site_id, :parent_id
	attr_accessor :url
	
	### FILTERS		--------------------------------------
	before_save 	:prep_redirect
	before_save		:clean_url

	### VALIDATIONS	--------------------------------------
	validate    :valid_url?

	validates	:title, :presence => true, :uniqueness => { :scope => [ :space_id, :type ] }

	### RELATIONSHIPS   	-------------------------------
	belongs_to	:user #the creator'
	belongs_to	:category
	belongs_to	:site

	has_many	:content_subscriptions, :as => :parent_object, :dependent => :destroy
	has_many	:subscribers, :through => :content_subscriptions, :source => :user, conditions: "content_subscriptions.status = 'active'"
	has_many	:user_content, :as => :parent_object

	### Plugins  	--------------------------------------
	extend FriendlyId
  	friendly_id :slugger, :use => :scoped, :scope => :site

	acts_as_taggable

	acts_as_nested_set

	has_paper_trail :ignore => [ :cached_view_count, :cached_rating_avg, :updated_at, :modified_at ]

	### Class Methods   	-------------------------------
	
	def self.archived( args={} )
		args[:year] ||= Time.now.year
		results = where( "year(publish_at) = :year", year: args[:year] )
		results = results.where( "month(publish_at) = :month ", month: args[:month] ) if args[:month].present?
		return results
	end

	def self.authored_by( user )
		where( user_id: user.id )
	end

	def self.dated_between( args={ start: 1.day.ago, end: Time.now } )
		where( "publish_at between ? and ?", args[:start], args[:end] )
	end

	def self.filter_by( field, value )
		return scoped if field.nil? || value.nil?
		where( field.to_sym => value )
	end

	def self.popular( num=5 )
		order( "cached_view_count desc" ).limit( num )
	end

	def self.dated_between( start_time=1.day.ago, end_time=Time.now )
		where( "publish_at between ? and ?", start_time, end_time )
	end

	def self.month_year( month=Time.now.month, year=Time.now.year )
		where( "month(publish_at) = ? and year(publish_at) = ?", month, year )
	end

	def self.year( year=Time.now.year )
		where( "year(publish_at) = ?", year )
	end

	def self.featured
		where( :is_featured => true )
	end

	def self.public
		where( :availability => 'public' )
	end

	def self.published
		where( "publish_at <= ? and status = 'published'", Time.now )
	end

	def self.draft
		where( :status => 'draft' )
	end

	def self.trash
		where( :status => 'trash' )
	end

	def self.recent( num=5 )
		order( "publish_at desc" ).limit( num )
	end

	### Instance Methods  	-------------------------------

	def linked_title( option=nil )
		"<a href='#{full_path}/#{self.slug}#{option}'>#{self.title}</a>"
	end

	# meant to be over-ridden by media instance classes.
	# defaults to /object_types/object.slug
	def path( args={} )
		controller = ''

		if args[:with_parent].present?
			controller = "/#{args[:with_parent].class.name.tableize}/#{args[:with_parent].slug}/"
		end

		controller += args[:controller] || self.type.tableize

		val = "/#{controller}/#{self.slug}"

		val = val + "." +  args[:format].to_s if args[:format].present?

		return val

	end

	def full_path( args={} )
		controller = args[:controller] || self.type.tableize
		args.merge!( { :controller => controller } )
		self.site.http_url + self.path( args )
	end

	def slugger
		if self.slug.blank? 
			if self.url.present?
				return self.url
			else
				return self.title
			end
		else
			if self.url.present?
				return self.url
			end
		end
	end

	def published?
		if self.publish_at.present?
			self.publish_at <= Time.now && self.status == 'published'
		else
			self.status == 'published'
		end
	end

	### Private  ----------------------------------------
	private

		def clean_url
			self.url.gsub!( /\W/, "-" ) unless self.url.blank?
		end

		def prep_redirect
			return if self.redirect_path.nil?
			self.redirect_path = "/#{self.redirect_path}" unless self.redirect_path.match( /\A\// )
		end

		def valid_url?
			app_routes =  Rails.application.routes.routes.map { |route| route.path.spec.to_s.match( /\w+\W/ ).to_s.chop }.uniq
			field_to_test = self.url.present? ? self.url : self.title.downcase.gsub( /\W/, '-' )
			if app_routes.include?( field_to_test )
				errors.add( :url, "Media URL #{field_to_test.inspect} Conflicts with existing routes." )
			end
		end

end