class BaseMigration < ActiveRecord::Migration

	def change
		
		create_table :app_events, force: true do |t|
			t.references 		:space
			t.references 		:parent_obj, polymorphic: true
			t.references		:user
			t.integer			:participant_id 				# reference to participant for tracking tests
			t.references		:referring_user
			t.string			:event
			t.integer 			:value
			t.string			:ip
			t.string 			:http_referrer
			t.string 			:path
			t.string 			:user_agent
			t.text 				:content
			t.string			:extra_data
			t.string			:status,		default: :published
			t.timestamps
		end

		add_index :app_events, :space_id
		add_index :app_events, [ :parent_obj_id, :parent_obj_type, :space_id ], name: 'index_app_events_on_parent'
		add_index :app_events, :referring_user_id
		add_index :app_events, :user_id 
		add_index :app_events, :participant_id
		add_index :app_events, [ :path, :space_id ]
		add_index :app_events, [ :event, :space_id ]
		add_index :app_events, [ :event, :ip, :space_id ]

		create_table :contacts do |t|
			t.references	:user
			t.string		:subject
			t.text			:content
			t.string		:status, default: :active
			t.string		:ip
			t.timestamps
		end
		add_index :contacts, :user_id


		create_table :media, :force => true do |t|
			t.references 		:space
			t.references  		:user
			t.references  		:parent
			t.references  		:category
			t.string   			:type
			t.integer			:lft
			t.integer			:rgt
			t.string 			:title
			t.string			:subtitle
			t.string			:title_tag
			t.string			:uri
			t.string 			:avatar
			t.text				:description
			t.text				:content
			t.string			:status,					default: :published
			t.string			:availability,				default: :public
			t.datetime			:publication_date
			t.datetime			:publish_at
			t.datetime			:modified_at
			t.integer			:seq
			t.string			:slug
			t.boolean 			:is_explicit,				default: false
			t.boolean			:is_commentable,			default: true
			t.boolean			:is_featured,				default: false
			t.boolean			:is_sticky,					default: false
			t.boolean			:is_shareable
			t.boolean			:is_title_visible
			t.boolean			:email_author_on_comment,	default: true
			t.string			:redirect_path
			t.integer			:cached_view_count,			default: 0
			t.timestamps
		end

		add_index :media, :space_id
		add_index :media, :user_id
		add_index :media, :category_id
		add_index :media, [ :type, :space_id ]
		add_index :media, [ :slug, :space_id ], 	unique: true


		create_table :nominations do |t|
			t.references 	:creator
			t.references	:user
			t.string		:email
			t.string		:name
			t.text			:who
			t.text			:why
			t.string		:where
			t.string		:status # brainstorm, consideration, evaluation, accepted
			t.timestamps
		end
		add_index :nominations, :creator_id
		add_index :nominations, :user_id


		create_table :oauth_credentials do |t|
			t.references	:user
			t.string		:provider
			t.string		:uid 
			t.string		:token 
			t.string		:secret
			t.timestamps
		end
		add_index :oauth_credentials, :user_id
		add_index :oauth_credentials, :provider
		add_index :oauth_credentials, :uid
		add_index :oauth_credentials, :token
		add_index :oauth_credentials, :secret


		create_table :roles do	|t|
			t.string 		:name
			t.timestamps
		end

		add_index :roles, :name


		create_table :spaces, :force => true do |t|
			t.references	:parent
			t.integer		:lft
			t.integer		:rgt
			t.string		:name
			t.string		:display_name
			t.text 			:description
			t.text			:purpose
			t.datetime		:purpose_due_at
			t.string		:comment_policy,	default: :published
			t.string		:http_username
			t.string		:http_password
			t.string		:status,			default: :published
			t.string		:availability,		default: :public
			t.timestamps
		end
		add_index :spaces, :name
		

		create_table :space_memberships do |t|
			t.references 	:user
			t.references	:space
			t.string		:status
			t.string		:role
			t.timestamps
		end
		add_index :space_memberships, :user_id
		add_index :space_memberships, :space_id
		

		create_table :taggings, :force => true do |t|
			t.references		:tag
			t.references		:taggable, 	polymorphic: true
			t.references		:tagger, 	polymorphic: true
			t.string			:context
			t.timestamps
		end

		add_index :taggings, :tag_id
		add_index :taggings, [ :taggable_id, :taggable_type, :context ]


		create_table :tags, :force => true do |t|
			t.string			:name
			t.timestamps
		end

		add_index :tags, :name, 	unique: true


		create_table :user_roles do |t|
			t.references 	:user
			t.references	:granting_user
			t.references 	:role
			t.timestamps
		end

		add_index :user_roles, :user_id
		add_index :user_roles, :granting_user_id
		add_index :user_roles, :role_id

		create_table :users do |t|
			t.string		:name
			t.string 		:slug
			t.string 		:first_name
			t.string 		:last_name
			t.string 		:avatar
			t.datetime 		:birthday
			t.string		:gender
			t.string		:status,				default: 'active'
			t.string 		:website_url
			t.text 			:bio
			t.text 			:sig
			t.string		:ip
			t.float			:latitude
			t.float 		:longitude
			t.boolean		:is_human, 				default: true

			## Database authenticatable
			t.string		:email,					null: false, default: ""
			t.string		:encrypted_password,	null: false, default: ""

			## Recoverable
			t.string		:reset_password_token
			t.datetime		:reset_password_sent_at

			t.string		:password_hint
			t.string		:password_hint_response

			## Rememberable
			t.datetime		:remember_created_at

			## Trackable
			t.integer		:sign_in_count, :default => 0
			t.datetime		:current_sign_in_at
			t.datetime		:last_sign_in_at
			t.string		:current_sign_in_ip
			t.string		:last_sign_in_ip

			## Confirmable
			t.string		:confirmation_token
			t.datetime		:confirmed_at
			t.datetime		:confirmation_sent_at
			t.string		:unconfirmed_email # Only if using reconfirmable

			## Lockable
			t.integer		:failed_attempts, 		default: 0 # Only if lock strategy is :failed_attempts
			t.string		:unlock_token # Only if unlock strategy is :email or :both
			t.datetime		:locked_at

			## Token authenticatable
			t.string		:authentication_token

			t.timestamps
		end

		add_index :users, :name
		add_index :users, :slug, 					unique: true
		add_index :users, :email
		add_index :users, :reset_password_token,	unique: true
		add_index :users, :confirmation_token,		unique: true
		add_index :users, :unlock_token,			unique: true
		add_index :users, :authentication_token,	unique: true



		create_table :versions, :force => true do |t|
			t.references	:item,		polymorphic: true
			t.string		:event, 	null: false
			t.string		:whodunnit
			t.text			:object
			t.text			:object_changes
			t.datetime		:created_at
		end

		add_index :versions, [ :item_type, :item_id ]


		create_table :votes do |t|
			t.references 	:votable, polymorphic: true
			t.references 	:user
			t.integer		:score
			t.string		:context
			t.text			:content
			t.timestamps
		end
		add_index :votes, [ :votable_id, :votable_type ]
		add_index :votes, :user_id

	end

end
