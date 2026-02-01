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

  def hide_ok
    @hide_ok ||= @options.fetch(:hide_ok, false)
  end

  def default_button
    tag.button class: 'd-btn d-tooltip', data: {
      tip: tooltip_value,
      action: 'click->destroy#click',
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
    @wrapper_tag ||= @options.fetch(:wrapper_tag, 'dialog')
  end

  def wrapper_classes
    @wrapper_classes ||= -> {
      default_classes = 'd-modal'
      new_classes = @options.fetch(:wrapper_classes, '')
      [default_classes, new_classes, modal_position].join(' ')
    }.call
  end

  def wrapper_data  
    @wrapper_data ||= @options.fetch(:wrapper_data, {
      controller: 'modal',
    })
  end

  def modal_size
    @modal_size ||= case @options.fetch(:size, 'md').to_sym
                    when :xs
                      'md:w-11/12 md:max-w-xs'
                    when :sm
                      'md:w-11/12 md:max-w-sm'
                    when :md
                      # default
                      ''
                    when :lg
                      'md:w-11/12 md:max-w-lg'
                    when :xl
                      'md:w-11/12 md:max-w-xl'
                    when :'2xl'
                      'md:w-11/12 md:max-w-2xl'
                    when :'3xl'
                      'md:w-11/12 md:max-w-3xl'
                    when :'4xl'
                      'md:w-11/12 md:max-w-4xl'
                    when :'5xl'
                      'md:w-11/12 md:max-w-5xl'
                    when :'6xl'
                      'md:w-11/12 md:max-w-6xl'
                    end
  end

  def modal_position
    # default position is bottom on small screens, middle on larger screens
    @modal_position ||= @options.fetch(:position, 'd-modal-bottom md:d-modal-middle')
  end
end
