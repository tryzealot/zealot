# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  DEFAULT_LABEL_CLASS = 'd-fieldset-legend'
  DEFAULT_INPUT_LABEL_CLASS = 'text-md font-semibold'
  DEFAULT_HINT_WRAP =  { tag: 'p', class: 'd-label mt-1 text-xs opacity-70 whitespace-normal break-words' }
  DEFAULT_ERROR_WRAP = { tag: 'p', class: 'mt-1 text-error text-xs whitespace-normal break-words' }

  # You can define the default class to be used on forms. Can be overriden
  # with `html: { :class }`. Defaulting to none.
  config.default_form_class = ''

  # Default class for buttons
  config.button_class = 'd-btn d-btn-primary'

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
  config.error_notification_class = 'd-alert d-alert-error'

  # Method used to tidy up errors. Specify any Rails Array method.
  config.error_method = :to_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = 'd-input-error'
  # config.input_field_valid_class = 'input-success'
  # config.label_class = 'text-md font-semibold'

  # vertical forms (default_wrapper)
  config.wrappers :vertical_form, tag: 'fieldset', class: 'd-fieldset mb-2' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'd-input w-full'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  end

  # vertical input for boolean (aka checkboxes)
  config.wrappers :vertical_boolean, tag: 'fieldset', class: 'd-fieldset mb-2' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'label', class: DEFAULT_INPUT_LABEL_CLASS, error_class: 'text-error' do |ba|
      ba.use :input, class: 'd-toggle d-toggle-primary mr-2'
      ba.use :label_text
    end
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  end

  # vertical input for radio buttons and check boxes
  config.wrappers :vertical_collection, tag: 'div',
                  class: 'd-fieldset mb-2',
                  item_wrapper_class: 'mb-1',
                  item_label_class: "#{DEFAULT_INPUT_LABEL_CLASS} pl-2" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'p', class: DEFAULT_LABEL_CLASS, error_class: 'text-error' do |ba|
      ba.use :label_text
    end
    b.use :input, class: 'd-radio d-radio-primary'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  end

  # vertical file input
  config.wrappers :vertical_file, tag: 'fieldset', class: 'd-fieldset mb-2' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'd-file-input w-full', error_class: 'd-input-error', valid_class: 'd-input-success'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  end

  # vertical select
  config.wrappers :vertical_select, tag: 'fieldset', class: 'd-fieldset mb-2' do |b|
    # b.use :html5
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'd-select w-full'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  end

  # vertical multi select
  # config.wrappers :vertical_multi_select, tag: 'fieldset', class: 'fieldset mb-2', error_class: 'f', valid_class: '' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.use :label, class: 'fieldset-legend', error_class: 'text-error'
  #   b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  #   b.wrapper tag: 'div', class: 'inline-flex space-x-1' do |ba|
  #     ba.use :input, class: 'select select-bordered', error_class: 'select-error', valid_class: 'select-success'
  #   end
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end

  # # vertical range
  # config.wrappers :vertical_range, tag: 'fieldset', class: 'fieldset mb-2' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.optional :step
  #   b.use :label, class: 'fieldset-legend', error_class: 'text-error'
  #   b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  #   b.use :input, class: 'range', error_class: 'range-error', valid_class: 'range-success'
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end

  # textarea
  config.wrappers :vertical_textarea, tag: 'fieldset', class: 'd-fieldset mb-2' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'd-textarea w-full'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  end

  config.wrappers :vertical_hidden do |b|
    b.use :html5
    b.optional :readonly
    b.use :input, type: :hidden
  end

  # # vertical date input
  # config.wrappers :vertical_date, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
  #   b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
  #   b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end

  # # vertical time input
  # config.wrappers :vertical_time, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
  #   b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
  #   b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end

  # # vertical date time
  # config.wrappers :vertical_datetime, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
  #   b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
  #   b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end

  # # vertical date time zone
  # config.wrappers :vertical_datetime_local, tag: 'fieldset', class: '', error_class: 'f', valid_class: '' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.use :label, class: 'label label-text text-sm block', error_class: 'text-error'
  #   b.use :input, class: 'input input-bordered', error_class: 'input-error', valid_class: 'input-success'
  #   b.use :full_error, wrap_with: { tag: 'p', class: 'mt-2 text-error text-xs' }
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end


  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :vertical_form

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper used for the input.
  config.wrapper_mappings = {
    boolean: :vertical_boolean,
    # range: :vertical_range,
    select: :vertical_select,
    file: :vertical_file,
    text: :vertical_textarea,
    check_boxes: :vertical_collection,
    collection: :vertical_collection,
    radio_buttons: :vertical_collection,
    hidden: :vertical_hidden,
    # date: :vertical_date,
    # datetime: :vertical_datetime,
    # time: :vertical_time,
    # datetime_local: :vertical_datetime_local,
  }
end
