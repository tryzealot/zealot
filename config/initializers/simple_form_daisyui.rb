# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # You can define the default class to be used on forms. Can be overriden
  # with `html: { :class }`. Defaulting to none.
  config.default_form_class = 'tw:space-y-4'

  # Default class for buttons
  config.button_class = 'tw:btn tw:btn-primary'

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
  config.error_notification_class = 'tw:alert tw:alert-error'

  # Method used to tidy up errors. Specify any Rails Array method.
  config.error_method = :to_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = 'tw:input-error'
  config.input_field_valid_class = 'tw:input-success'
  config.label_class = 'tw:label-text tw:text-sm'

  # vertical forms
  #
  # vertical default_wrapper
  config.wrappers :vertical_form, tag: 'fieldset', class: 'tw:fieldset ' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'tw:fieldset-legend', error_class: 'tw:text-error'
    b.use :input, class: 'tw:input tw:w-full', error_class: 'tw:input-error', valid_class: 'tw:input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'tw:mt-2 tw:text-error tw:text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'tw:label' }
  end

  # vertical input for boolean (aka checkboxes)
  config.wrappers :vertical_boolean, tag: 'fieldset', class: 'fieldset', error_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :input, class: 'tw:checkbox', error_class: 'tw:input-error', valid_class: 'tw:input-success'
    b.use :label, class: 'tw:font-bold tw:text-base-content tw:pl-2', error_class: 'tw:text-error'
    b.use :hint, wrap_with: { tag: 'p', class: 'tw:pt-2 tw:block tw:text-xs tw:opacity-70' }
    b.use :full_error, wrap_with: { tag: 'p', class: 'tw:block tw:text-error tw:text-xs' }
  end

  # vertical input for radio buttons and check boxes
  config.wrappers :vertical_collection, tag: 'div',
                  class: 'fieldset',
                  item_wrapper_class: 'tw:mb-1',
                  item_label_class: 'tw:font-bold tw:text-base-content tw:pl-2' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'legend', class: 'tw:fieldset-legend', error_class: 'tw:text-error' do |ba|
      ba.use :label_text
    end

    b.use :input, class: 'tw:radio', error_class: 'tw:text-error', valid_class: 'tw:text-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'tw:block tw:mt-2 tw:text-error tw:text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'tw:mt-2 tw:text-xs tw:opacity-70' }
  end

  # vertical file input
  config.wrappers :vertical_file, tag: 'fieldset', class: '' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: 'tw:label tw:label-text text-sm block', error_class: 'tw:text-error'
    b.use :input, class: 'file-input file-input-bordered', error_class: 'input-error',
                  valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'tw:mt-2 tw:text-error tw:text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'tw:mt-2 tw:text-xs tw:opacity-70' }
  end

  # vertical multi select
  config.wrappers :vertical_multi_select, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.wrapper tag: 'div', class: 'inline-flex space-x-1' do |ba|
      ba.use :input, class: 'select select-bordered', error_class: 'select-error', valid_class: 'select-success'
    end
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical date input
  config.wrappers :vertical_date, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical time input
  config.wrappers :vertical_time, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical date time
  config.wrappers :vertical_datetime, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical date time zone
  config.wrappers :vertical_datetime_local, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
    b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-2 text-xs opacity-70' }
  end

  # vertical select
  config.wrappers :vertical_select, tag: 'div', class: '', error_class: 'f', valid_class: '' do |b|
    # b.use :html5
    b.optional :readonly
    b.use :label, class: 'tw:fieldset-legend', error_class: 'tw:text-error'
    b.use :input, class: 'tw:select', error_class: 'tw:select-error', valid_class: 'tw:select-success'
    b.use :full_error, wrap_with: { tag: 'p', class: 'tw:mt-2 tw:text-error tw:text-xs' }
    b.use :hint, wrap_with: { tag: 'p', class: 'tw:label' }
  end

  # vertical range
  config.wrappers :vertical_range, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
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
