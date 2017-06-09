module Wechat
  class LocationMessage < Message

    def Location_X
      @source.Location_X.to_f
    end

    def Location_Y
      @source.Location_Y.to_f
    end

    def Scale
      @source.Scale.to_i
    end
  end
end
