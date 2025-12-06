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

    raise 'Not found preset or missing on, off propteries' if @on.blank? || @off.blank?
  end

  def load_preset(options)
    PRESETS[options[:preset].to_sym] || [nil, nil]
  end

  def label_tag(&block)
    options = @options.delete(:label) || {}
    options[:class] = ['d-swap', @styles, options[:class]].compact.join(' ')
    tag.label(**options, &block)
  end

  def input_tag
    options = @options.delete(:input) || {}
    tag.input(type: :checkbox, **options)
  end
end
