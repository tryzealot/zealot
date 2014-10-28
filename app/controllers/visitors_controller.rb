class VisitorsController < ApplicationController

  def upload
 #  	gzip = ActiveSupport::Gzip.compress('compress me!')
	ungzip = ActiveSupport::Gzip.decompress(request.raw_post)

	data = MultiJson.load request.raw_post
	# raw = ActiveSupport::Gzip.decompress('compress me!')
 	render json: {
   		# gzip: gzip,
   		# ungzip: ungzip,
   		body: data
    }
  end
end