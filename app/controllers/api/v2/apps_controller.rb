class Api::V2::AppsController < ActionController::API
  def index
    @apps = App.all
    render @apps
  end
end