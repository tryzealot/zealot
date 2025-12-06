# frozen_string_literal: true

class SwapIconComponent < ViewComponent::Base
  PRESETS = {
    switch: {
      on: 'fa-solid fa-minus',
      off: 'fa-solid fa-plus'
    }
  }

  def initialize(**options)
    preset = load_preset(options)
    @options = options
    @on = options.fetch(:on, preset[:on])
    @off = options.fetch(:off, preset[:off])

    raise 'Not found preset or missing on, off propteries' if @on.blank? || @off.blank?
  end

  def load_preset(options)
    PRESETS[options[:preset].to_sym] || [nil, nil]
  end

  def input_tag
    data = {}
    data[:action] = @options[:click] if @options[:click]
    tag.input(type: :checkbox, data: data)
  end
end
