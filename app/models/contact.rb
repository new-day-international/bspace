class Contact < ActiveRecord::Base
	attr_protected	:none
	attr_accessor	:name, :email

	belongs_to :user


end