module Wechat
  class TextReplyMessage < ReplyMessage
    xml_accessor :Content, :cdata => true
    def initialize
      super
      @MsgType = 'text'
    end
  end
end
