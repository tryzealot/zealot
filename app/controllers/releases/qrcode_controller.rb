# frozen_string_literal: true

class Releases::QrcodeController < ApplicationController
  before_action :set_release

  ##
  # 显示应用的二维码
  # GET /apps/:slug/(:version)/qrcode
  def show
    render qrcode: friendly_channel_release_url(@release.channel, @release),
           module_px_size: qrcode_size,
           fill: '#FFFFFF',
           color: '#465960'
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
