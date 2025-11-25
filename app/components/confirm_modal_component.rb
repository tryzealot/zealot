# frozen_string_literal: true

class ConfirmModalComponent < ViewComponent::Base
  def initialize(body, confirm_link: nil, title: nil, **options)
    @body = body
    @title = title
    @confirm_link = confirm_link
    @options = options

    @element = options.fetch(:element, 'div')
    @classes = options.fetch(:classes, nil)
  end

  def default_button
    tag.button class: 'btn btn-tool', title: tooltip_value, data: { 
      action: 'click->destroy#click', 
      bs_toggle: 'tooltip', 
      bs_custom_class: 'default-tooltip' 
    } do
      tag.i class: 'fa-solid fa-trash-alt text-danger'
    end
  end

  def tooltip_value
    @options[:tooltip_value] || raise(ArgumentError, 'tooltip_value is required')
  end

  def confirm_value
    @options[:confirm_value] || raise(ArgumentError, 'confirm_value is required')
  end

  def cancel_value
    @options[:cancel_value] || raise(ArgumentError, 'cancel_value is required')
  end
end
