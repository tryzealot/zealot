# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  def initialize(message, type: :info, **options)
    @message, @title, @options = extract_flash_args(message, options)
    @type = type.to_sym
    @options[:delay] ||= 4000
    @style = style_for(@type)
    @icon  = icon_for(@type)
  end

  private

  def extract_flash_args(message, options)
    if message.is_a?(Hash)
      [
        message[:message],
        message[:title],
        options.merge(message.except(:title, :message))
      ]
    else
      [
        message,
        options.delete(:title),
        options
      ]
    end
  end

  def style_for(type)
    {
      notice: 'd-alert-success',
      warn:   'd-alert-warning',
      alert:  'd-alert-error'
    }[type] || 'd-alert-info'
  end

  def icon_for(type)
    {
      notice: 'circle-check',
      warn:   'circle-exclamation',
      alert:  'circle-xmark'
    }[type] || 'circle-info'
  end
end
