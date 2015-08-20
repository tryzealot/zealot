#Exception Handler
###
#You can add different settings using this block
#Use the docs at http://github.com/richpeck/exception_handler for info
###
ExceptionHandler.setup do |config|

	#DB -
	#Options = false / true
	config.db = true

	#Email -
	#Default = false / true
	#config.email =

	#Social
	config.social = {
		twitter: 	"http://twitter.com/icyleaf",
		facebook: 	"https://facebook.com/icyleaf",
	}

end
