class ChatroomsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @chatrooms = Chatroom.where.not(id:143).all
  end

  def show
    chatroom_id = params[:id]

    @chatroom = Chatroom.find(chatroom_id)


    # url = 'http://api.im.qyer.com/v1/im/topics/history.json'
    # params = {
    #   :key => '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
    #   :topic_id => @chatroom.im_topic_id,
    #   :limit => 20,
    #   :b => 1
    # }

    # r = RestClient.get url, {:params => params}
    # data = MultiJson.load r
    # if data['meta']['code'] == 200
    #   data['response']['messages'].each do |m|
    #     begin
    #       member = Member.find_by(im_user_id:m['from'])

    #       next unless member

    #       Message.find_or_create_by(im_id:m['msg_id']) do |message|
    #         message.im_id = m['msg_id']
    #         message.im_user_id = m['from']
    #         message.im_topic_id = m['topic_id']
    #         message.user_id = member.user_id
    #         message.user_name = member.people.username
    #         message.chatroom_id = @chatroom.id
    #         message.chatroom_name = @chatroom.chatroom_name
    #         message.message = m['message'] if m['content_type'] == 'text' 
    #         message.custom_data = MultiJson.dump(m['customData'])
    #         message.content_type = m['content_type']
    #         message.file_type = (m['fileType'] || nil)
    #         message.file =  m['message'] if m['content_type'] != 'text' 
    #         message.timestamp = Time.at(m['timestamp'] / 1000).utc
    #       end
    #     rescue Exception => e
    #       next
    #     end
    #   end
    # end




    @messages = Message.where(chatroom_id:chatroom_id)
      .order('timestamp DESC')
      .paginate(:page => params[:page])
  end
end
