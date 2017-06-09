module Wechat
  class LinkReplyMessage < ReplyMessage
    xml_accessor :Title, :cdata   => true
    xml_accessor :Description, :cdata   => true
    xml_accessor :Url, :cdata   => true

    def initialize
      super
      @MsgType = 'link'
    end
  end
end
