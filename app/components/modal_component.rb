# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  def initialize(**options)
    @options = options

    @element = options.fetch(:element, 'div')
    @classes = options.fetch(:classes, nil)
  end

  def body
    @body ||= -> {
      @options[:body] || raise(ArgumentError, 'body is required')
    }.call
  end

  def title
    @title ||= @options.fetch(:title, nil)
  end

  def type
    @type ||= @options.fetch(:type, 'default')
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

  def close_button
    @close_button ||= @options.fetch(:close_button, true)
  end

  def tooltip_value
    @tooltip_value ||= -> {
      @options[:tooltip_value] || raise(ArgumentError, 'tooltip_value is required')
    }.call
  end

  def confirm_value
    @confirm_value ||= -> {
      @options[:confirm_value] || raise(ArgumentError, 'confirm_value is required')
    }.call
  end

  def cancel_value
    @cancel_value ||= -> {
      @options[:cancel_value] || raise(ArgumentError, 'cancel_value is required')
    }.call
  end
  
  def wrapper_tag
    @wrapper_tag ||= @options.fetch(:wrapper_tag, 'div')
  end

  def wrapper_classes
    @wrapper_classes ||= -> {
      default_classes = 'modal fade'
      modal_size = @options.fetch(:size, nil)
      modal_size = [(modal_size ? "modal-#{modal_size}" : nil)].compact.join(' ')
      new_classes = @options.fetch(:wrapper_classes, '')
      [default_classes, new_classes, modal_size].join(' ')
    }.call
  end

  def wrapper_data  
    @wrapper_data ||= @options.fetch(:wrapper_data, {
      controller: 'modal',
    })
  end
end
