module Wechat
  class VideoMessage < Message

    def MediaId
      @source.MediaId
    end

    def ThumbMediaId
      @source.ThumbMediaId
    end
  end
end
