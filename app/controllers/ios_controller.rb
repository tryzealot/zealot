class IosController < ApplicationController
  load_and_authorize_resource :class => Ios
  
  before_filter :authenticate_user!

  def index
    @ioses = Ios.all
  end

  def download
    ios = Ios.find(params[:id])

    file = "public/uploads/ipa/#{ios.dsym_file}"
    send_file file, :type => 'application/zip', :x_sendfile => true
  end
	
end
