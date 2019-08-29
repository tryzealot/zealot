class Api::V2::Apps::TestController < ActionController::API
  def show
    @release = Release.find 16

    render json: @release,
           serializer: Api::UploadAppSerializer,
           status: :created
  end
end
