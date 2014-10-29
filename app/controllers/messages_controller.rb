class MessagesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @messages = Message.order('timestamp DESC').paginate(:page => params[:page])
  end

end