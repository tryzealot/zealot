# frozen_string_literal: true

module Qrcode
  extend ActiveSupport::Concern

  THEMES = {
    light: {
      fill: '#FFFFFF',
      color: '#465960'
    },
    dark: {
      fill: '#212529',
      color: '#dedcdc'
    },
  }

  def qrcode_options
    {
      module_px_size: px_size,
      fill: theme[:fill],
      color: theme[:color],
      offset: 10
    }
  end

  private

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
    when 'extra'
      8
    else
      2
    end
  end
end
