# frozen_string_literal: true

class SwapIconComponent < ViewComponent::Base
  PRESETS = {
    switch: {
      styles: 'd-swap-rotate',
      on: 'fa-solid fa-minus',
      off: 'fa-solid fa-plus'
    },
    hamburger: {
      styles: 'd-swap-rotate',
      on: 'fa-solid fa-xmark',
      off: 'fa-solid fa-bars'
    }
  }

  def initialize(**options)
    preset = load_preset(options)
    @options = options
    @on = options.delete(:on) || preset[:on]
    @off = options.delete(:off) || preset[:off]
    @styles = preset[:styles]
    @manual_toggle = false
  end

  def load_preset(options)
    PRESETS[options[:preset].to_sym] || [nil, nil]
  end

  def label_tag(&block)
    options = @options.delete(:label) || {}
    @manual_toggle = options[:for].present?
    if manual_toggle?
      options[:data] ||= {}
      options[:data][:controller] = concat_data(options[:data][:controller], 'swap-icon')
      options[:data][:action] = concat_data(options[:data][:action], 'click->swap-icon#sync')
    end
    options[:class] = ['d-swap', @styles, options[:class]].compact.join(' ')
    tag.label(**options, &block)
  end

  def input_tag
    options = @options.delete(:input) || {}
    options[:type] ||= :checkbox
    if manual_toggle?
      options[:data] ||= {}
      options[:data][:'swap-icon-target'] ||= 'input'
    end
    tag.input(**options)
  end

  private

  attr_reader :manual_toggle

  def manual_toggle?
    @manual_toggle
  end

  def concat_data(current, extra)
    [current, extra].compact.join(' ')
  end
end
