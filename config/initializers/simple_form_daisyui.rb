# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Default class for buttons
  config.button_class = 'btn btn-primary btn-sm my-2'

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = ''

  # How the label text should be generated altogether with the required text.
  config.label_text = ->(label, required, _explicit_label) { "#{label} #{required}" }

  # Define the way to render check boxes / radio buttons with labels.
  config.boolean_style = :inline

  # You can wrap each item in a collection of radio/check boxes with a tag
  config.item_wrapper_tag = :fieldset

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  config.include_default_input_wrapper_class = false

  # CSS class to add for error notification helper.
  config.error_notification_class = 'alert alert-error'

  # Method used to tidy up errors. Specify any Rails Array method.
  config.error_method = :to_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = 'input-error'
  config.input_field_valid_class = 'input-success'
  config.label_class = 'label-text text-sm'

  # vertical forms
  #
  # vertical default_wrapper
  config.wrappers :vertical_form, tag: 'fieldset', class: 'mb-4' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'fieldset-legend', error_class: 'text-error'
    b.use :input, class: 'input validator', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'label validaEtor-hint' }
  end

  # vertical input for boolean (aka checkboxes)
  config.wrappers :vertical_boolean, tag: 'fieldset', class: 'mb-4', error_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :input, class: 'checkbox checkbox-primary'
    b.use :label, class: 'label pl-1', error_class: 'text-error'
    b.use :hint, wrap_with: { tag: 'p', class: 'block text-xs opacity-70' }
    b.use :full_error, wrap_with: { tag: 'p', class: 'block text-error text-xs' }
  end

  # vertical input for radio buttons and check boxes
  config.wrappers :vertical_collection, 
                  item_wrapper_class: 'flex items-center',
                  item_label_class: 'my-1 ml-3 label-text text-sm', tag: 'div', class: 'my-4' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'legend', class: 'label-text text-sm',
                           error_class: 'text-error' do |ba|
      ba.use :label_text
    end
    b.use :input,
          class: 'radio radio-primary', error_class: 'text-error', valid_class: 'text-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'block mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical file input
  config.wrappers :vertical_file, tag: 'div', class: '' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'file-input file-input-bordered w-full', error_class: 'input-error',
                  valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical multi select
  config.wrappers :vertical_multi_select, tag: 'div', class: 'my-4', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.wrapper tag: 'div', class: 'inline-flex space-x-1' do |ba|
      ba.use :input, class: 'select select-bordered w-full', error_class: 'select-error', valid_class: 'select-success'
    end
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical date input
  config.wrappers :vertical_date, tag: 'div', class: 'my-4', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered w-full', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical time input
  config.wrappers :vertical_time, tag: 'div', class: 'my-4', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered w-full', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical date time
  config.wrappers :vertical_datetime, tag: 'div', class: 'my-4', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered w-full', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical date time zone
  config.wrappers :vertical_datetime_local, tag: 'div', class: 'my-4', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered w-full', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical select
  config.wrappers :vertical_select, tag: 'div', class: 'my-4', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'select select-bordered w-full', error_class: 'select-error', valid_class: 'select-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical range
  config.wrappers :vertical_range, tag: 'div', class: 'my-4', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.optional :step
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'range', error_class: 'range-error', valid_class: 'range-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :vertical_form

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper used for the input.
  config.wrapper_mappings = {
    boolean: :vertical_boolean,
    check_boxes: :vertical_collection,
    collection: :vertical_collection,
    date: :vertical_date,
    datetime: :vertical_datetime,
    file: :vertical_file,
    radio_buttons: :vertical_collection,
    range: :vertical_range,
    select: :vertical_select,
    time: :vertical_time,
    datetime_local: :vertical_datetime_local
  }
end
