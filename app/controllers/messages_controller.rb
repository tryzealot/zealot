class MessagesController < ApplicationController
  load_and_authorize_resource

  before_filter :authenticate_user!
  
  def index
    @messages = Message.order('timestamp DESC').paginate(:page => params[:page])
  end

end