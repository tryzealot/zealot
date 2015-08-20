module ExceptionHandler
	class Error < ActiveRecord::Base
		#Table is called "errors"
		#Dev needs to use migration to create db

		#Associations
		belongs_to :usable, polymorphic: true
	end
end