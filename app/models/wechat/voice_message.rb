module Wechat
  class VoiceMessage < Message

    def MediaId
      @source.MediaId
    end

    def Format
      @source.Format
    end
  end
end
