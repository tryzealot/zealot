class Api::V2::AppsController < ActionController::API

  def index
    @apps = App.all
    render json: @apps, each_serializer: Api::AppsSerializer
  end
end