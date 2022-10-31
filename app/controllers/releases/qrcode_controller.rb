# frozen_string_literal: true

class Releases::QrcodeController < ApplicationController
  before_action :set_release

  THEMES = {
    light: {
      fill: '#FFFFFF',
      color: '#465960'
    },
    dark: {
      fill: '#343a40',
      color: '#F0F4Fb'
    },
  }

  ##
  # 显示应用的二维码
  # GET /apps/:slug/(:version)/qrcode
  def show
    render qrcode: friendly_channel_release_url(@release.channel, @release), **options
  end

  private

  def options
    {
      module_px_size: px_size,
      fill: theme[:fill],
      color: theme[:color]
    }
  end

  def theme
    @theme ||= -> do
      name = params.fetch(:theme, 'light') == 'light' ? :light : :dark
      THEMES[name]
    end.call
  end

  def px_size
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
