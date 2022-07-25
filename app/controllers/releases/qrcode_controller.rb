# frozen_string_literal: true

class Releases::QrcodeController < ApplicationController
  before_action :set_release

  LIGHT_BACKGROUND_COLOR = 'FFFFFF'
  LIGHT_COLOR = '465960'

  ##
  # 显示应用的二维码
  # GET /apps/:slug/(:version)/qrcode
  def show
    options = {
      module_px_size: qrcode_size,
      fill: "##{params.fetch(:fill, LIGHT_BACKGROUND_COLOR)}",
      color: "##{params.fetch(:color, LIGHT_COLOR)}"
    }

    render qrcode: friendly_channel_release_url(@release.channel, @release), **options
  end

  private

  def qrcode_size
    case params[:size]
    when 'thumb'
      3
    when 'medium'
      5
    when 'large'
      6
    else
      2
    end
  end

  def set_release
    @release = Release.find params[:release_id]
  end
end
