module Wechat
  class ShortVideoMessage < Message

    def MediaId
      @source.MediaId
    end

    def ThumbMediaId
      @source.ThumbMediaId
    end
  end
end
