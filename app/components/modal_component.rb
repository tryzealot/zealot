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

  # FIXME: migrate bootstrap tooltip to daisyUI
  def default_button
    tag.button class: 'btn btn-tool', title: tooltip_value, data: {
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
      default_classes = 'modal'
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
                      'w-11/12 max-w-xs'
                    when :sm
                      'w-11/12 max-w-sm'
                    when :md
                      # default
                      ''
                    when :lg
                      'w-11/12 max-w-lg'
                    when :xl
                      'w-11/12 max-w-xl'
                    when :'2xl'
                      'w-11/12 max-w-2xl'
                    when :'3xl'
                      'w-11/12 max-w-3xl'
                    when :'4xl'
                      'w-11/12 max-w-4xl'
                    when :'5xl'
                      'w-11/12 max-w-5xl'
                    end
  end

  def modal_position
    # default position is bottom on small screens, middle on larger screens
    @modal_position ||= @options.fetch(:position, 'modal-bottom sm:modal-middle')
  end
end
