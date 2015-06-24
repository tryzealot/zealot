class Api::ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  
  respond_to :json
end
