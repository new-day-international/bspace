
class AppEvent < ActiveRecord::Base

	self.table_name = 'app_events'
	attr_protected :none

	### FILTERS		--------------------------------------------

	### RELATIONSHIPS   	--------------------------------------
	belongs_to 	:user
	belongs_to	:owner, polymorphic: true
	belongs_to	:site
	belongs_to	:referring_user, class_name: 'User', foreign_key: :referring_user_id
	belongs_to 	:guest, class_name: 'User', foreign_key: :guid

	### Class Methods   	--------------------------------------
	def self.by_http_referrer( http_referrer=nil )
		return scoped if http_referrer.nil?
		where( http_referrer: http_referrer )
	end

	def self.by_ip( ip=nil )
		return scoped if ip.nil?
		where( ip: ip )
	end

	def self.by_object( obj )
		return scoped if obj.nil?
		where( parent_obj_type: obj.class.name ).where( parent_obj_id: obj.id )
	end

	def self.by_referring_user( user )
		return scoped if user.nil?
		where( referring_user_id: user.id )
	end

	def self.dated_between( start_date=1.month.ago, end_date=1.month.from_now )
		where( "created_at between ? and ?", start_date, end_date )
	end

	def self.event_list
		[
			:achievement,
			:avatar_update,
			:comment,
			:downvote,
			:email_open,
			:faq,
			:flag,
			:forum_post,
			:forum_topic,
			:login,
			:mention,
			:optin,
			:outbound,
			:publish,
			:purchase,
			:registration,
			:sample,
			:search,
			:upvote,
			:view,
			:visit
		]
	end

	def self.filter_by( field, value )
		return scoped if field.nil? || value.nil?
		where( field.to_sym => value )
	end

	def self.for_path( path )
		return scoped if path.nil?
		where( path: path )
	end

	def self.public_events
		# these events are broadcast to site_activities
		# todo -- can someday allow sites to customize which events are broadcast via broadcast_events table
		where( event: [ :avatar_update, :comment, :achievement, :forum_post, :forum_topic, :publish, :registration, :mention ] )

		# verbose broadcasting.... TODO reset to above before launch
		# where( "event is not null" )
	end

	def self.recent( num=10 )
		order( 'created_at desc' ).limit( num )
	end

	def self.record( event, args={} )
		event = event.to_s
		user = args[:user]
		parent_obj = args[:on]
		site = args[:site] || owner.try( :site ) || user.site
		rate = args[:rate] || 1.minute
		ip = args[:request].try( :ip )
		path = args[:request].try( :path )
		referring_user_id = args[:referring_user_id]

		return false unless user.present?

		# setting owner_type so logging with nill owner doesn't populate owner_type with NilClass
		parent_obj_type = parent_obj.nil? ? nil : parent_obj.class.name

		if parent_obj.nil?
			return false if self.where( event: event, user_id: user.id ).by_ip( ip ).for_path( path ).within_last( rate ).count > 0
		else
			return false if self.where( event: event, user_id: user.id ).by_ip( ip ).by_object( parent_obj ).within_last( rate ).count > 0
		end

		app_event = self.create( site_id: site.id, parent_obj_id: parent_obj.try( :id ), parent_obj_type: parent_obj_type,
						user_id: user.id, participant_id: args[:pid], referring_user_id: referring_user_id,
						event: event, value: args[:value], request: args[:request],
						content: args[:content], extra_data: args[:extra_data] )

		count_cache_field = "cached_#{event}_count"

		if parent_obj.present? && parent_obj.respond_to?( count_cache_field )
			eval "parent_obj.update_attributes( '#{count_cache_field}'.to_sym => parent_obj.#{count_cache_field} + 1 )"
		end

		return app_event

	end

	def self.referrals
		where( 'referring_user_id is not null' )
	end

	def self.within_last( period=1.minute )
		period_ago = Time.now - period
		where( "created_at >= ?", period_ago.getutc )
	end

	### Instance Methods  	--------------------------------------

	def request=( request )
		return if request.nil?

		self.ip = request.ip
		self.http_referrer = request.referrer
		self.user_agent = request.env['HTTP_USER_AGENT']
		self.path = request.path
	end

end
