# frozen_string_literal: true

module Qrcode
  extend ActiveSupport::Concern

  THEMES = {
    light: {
      fill: 'FFFFFF',
      color: '465960'
    },
    dark: {
      fill: '000000',
      color: 'DEDCDC'
    },
  }

  def qrcode_options
    options = {
      offset: 0,
      module_px_size: size,
      color: theme[:color],
    }
  
    case params[:format]
    when 'png'
      options.merge!({
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        resize_exactly_to: false,
        resize_gte_to: false,
        fill: theme[:fill],
        offset: 10
      })
    else
      options.merge!({
        shape_rendering: 'crispEdges',
        standalone: true,
        use_path: true,
        module_px_size: size,
        color: theme[:color],
      })
    end

    options
  end

  private

  def theme
    @theme ||= THEMES[params.fetch(:theme, 'light').to_sym] || :light
  end

  def size
    case params.fetch(:size, 'md')
    when 'sm'
      3
    when 'md'
      5
    when 'lg'
      7
    when 'xl'
      9
    else
      # xs
      2
    end
  end
end
