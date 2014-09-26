class ChatroomsController < ApplicationController

  def index
    @chatrooms = Chatroom.all
    
  end
end
