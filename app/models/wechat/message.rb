MultiXml.parser = :nokogiri

module Wechat
  class Message

    def initialize(hash)
      @source = OpenStruct.new(hash)
    end

    def method_missing(method, *args, &block)
      @source.send(method, *args, &block)
    end

    def CreateTime
      @source.CreateTime.to_i
    end

    def MsgId
      @source.MsgId.to_i
    end

    def self.factory(xml)
      hash = MultiXml.parse(xml)['xml']
      case hash['MsgType']
      when 'text'
        TextMessage.new(hash)
      when 'image'
        ImageMessage.new(hash)
      when 'location'
        LocationMessage.new(hash)
      when 'link'
        LinkMessage.new(hash)
      when 'event'
        EventMessage.new(hash)
      when 'voice'
        VoiceMessage.new(hash)
      when 'video'
        VideoMessage.new(hash)
      when 'shortvideo'
        ShortVideo.new(hash)
      else
        raise ArgumentError, 'Unknown Weixin Message'
      end
    end

  end
end
