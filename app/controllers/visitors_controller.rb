class VisitorsController < ApplicationController
  protect_from_forgery with: :null_session
  respond_to :json

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