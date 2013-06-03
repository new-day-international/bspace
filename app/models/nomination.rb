class Nomination < ActiveRecord::Base

	attr_protected :none

	belongs_to :creator, class_name: 'User'
	belongs_to :user 

	has_many 	:votes, as: :votable


	validates	:email, presence: true, uniqueness: { case_sensitive: false }
	validates	:name, presence: true, uniqueness: { case_sensitive: false }

end