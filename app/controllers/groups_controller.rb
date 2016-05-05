class GroupsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @title = '聊天室列表'
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
    @title = "#{@group.name} - 聊天记录"
    @messages = Message.where(group: @group)
                       .order('timestamp DESC')
                       .page(params[:page])

    render 'groups/messages'
  end

  def messages
    @title = '聊天记录'
    @messages = Message.order('timestamp DESC').page(params[:page])
  end

  def sync
    @group = Group.find(params[:id])
    url = 'http://api.im.qyer.com/v1/im/topics/history.json'
    params = {
      key: '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx',
      topic_id: @group.im_id,
      limit: 20,
      b: 1
    }

    r = RestClient.get url, params: params
    data = JSON.parse r
    if data['meta']['code'] == 200
      data['response']['messages'].each do |m|
        begin
          member = Member.find_by(im_user_id: m['from'])
          next unless member

          Message.find_or_create_by(im_id: m['msg_id']) do |message|
            message.im_id = m['msg_id']
            message.im_user_id = m['from']
            message.im_topic_id = m['topic_id']
            message.user_id = member.user_id
            message.user_name = member.people.username
            message.group_id = @group.id
            message.group_name = @group.name
            message.group_type = @group.type
            message.message = m['message'] if m['content_type'] == 'text'
            message.custom_data = JSON.dump(m['customData'])
            message.content_type = m['content_type']
            message.file_type = (m['fileType'] || nil)
            message.file = m['message'] if m['content_type'] != 'text'
            message.timestamp = Time.at(m['timestamp'] / 1000).utc
          end
        rescue
          next
        end
      end
    end

    flash[:notice] = '最新聊天记录已刷新'
    redirect_to action: :show
  end
end
