module Wechat
  class ReplyMessage
    include ROXML
    xml_name :xml

    xml_accessor :ToUserName, :cdata   => true
    xml_accessor :FromUserName, :cdata => true
    xml_reader   :CreateTime, :as => Integer
    xml_reader   :MsgId, :as => Integer
    xml_reader   :MsgType, :cdata => true

    def initialize
      @CreateTime = Time.now.to_i
      @MsgId = 64.times.map {rand(1..9)}.join.to_i
    end

    def to_xml
      super.to_xml(:encoding => 'UTF-8', :indent => 0, :save_with => 0)
    end
  end
end
