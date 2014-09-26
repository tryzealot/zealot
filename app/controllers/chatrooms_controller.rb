class ChatroomsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @chatrooms = Chatroom.where.not(id:143).all
  end

  def show
    chatroom_id = params[:id]

    @chatroom = Chatroom.find(chatroom_id)
    @messages = Message.where(chatroom_id:chatroom_id)
      .order('timestamp DESC')
      .paginate(:page => params[:page])
  end
end
