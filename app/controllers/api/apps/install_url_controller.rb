# 依赖 view 只能继承 ApplicationController
class Api::Apps::InstallUrlController < ApplicationController
  def show
    @release = Release.find_by_channel params[:slug], params[:version]
    if @release
      render content_type: 'text/xml', layout: false
    else
      render json: { error: 'No found app or release version' }, status: :not_found
    end
  end
end
