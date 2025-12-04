# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  DEFAULT_LABEL_CLASS = 'tw:fieldset-legend'
  DEFAULT_INPUT_LABEL_CLASS = 'tw:text-md tw:font-semibold'
  DEFAULT_HINT_WRAP =  { tag: 'p', class: 'tw:label tw:mt-1 tw:text-xs tw:opacity-70 tw:whitespace-normal tw:break-words' }
  DEFAULT_ERROR_WRAP = { tag: 'p', class: 'tw:mt-1 tw:text-error tw:text-xs tw:whitespace-normal tw:break-words' }

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
  config.error_method = :titem_wrapper_tago_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = 'tw:input-error'
  # config.input_field_valid_class = 'tw:input-success'
  # config.label_class = 'tw:text-md tw:font-semibold'

  # vertical forms (default_wrapper)
  config.wrappers :vertical_form, tag: 'fieldset', class: 'tw:fieldset' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'tw:text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'tw:input tw:w-full'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  end

  # vertical input for boolean (aka checkboxes)
  config.wrappers :vertical_boolean, tag: 'fieldset', class: 'tw:fieldset' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'label', class: DEFAULT_INPUT_LABEL_CLASS, error_class: 'tw:text-error' do |ba|
      ba.use :input, class: 'tw:toggle tw:toggle-primary tw:mr-2'
      ba.use :label_text
    end
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  end

  # vertical input for radio buttons and check boxes
  config.wrappers :vertical_collection, tag: 'div',
                  class: 'tw:fieldset',
                  item_wrapper_class: 'tw:mb-1',
                  item_label_class: "#{DEFAULT_INPUT_LABEL_CLASS} tw:pl-2" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'p', class: DEFAULT_LABEL_CLASS, error_class: 'tw:text-error' do |ba|
      ba.use :label_text
    end
    b.use :input, class: 'tw:toggle tw:toggle-primary'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  end

  # vertical file input
  config.wrappers :vertical_file, tag: 'fieldset', class: 'tw:fieldset' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'tw:text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'tw:file-input tw:w-full', error_class: 'tw:input-error', valid_class: 'tw:input-success'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  end

  # vertical select
  config.wrappers :vertical_select, tag: 'fieldset', class: 'tw:fieldset' do |b|
    # b.use :html5
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'tw:text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'tw:select tw:w-full'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  end

  # vertical multi select
  # config.wrappers :vertical_multi_select, tag: 'fieldset', class: 'tw:fieldset', error_class: 'f', valid_class: '' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.use :label, class: 'tw:fieldset-legend', error_class: 'tw:text-error'
  #   b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  #   b.wrapper tag: 'div', class: 'inline-flex space-x-1' do |ba|
  #     ba.use :input, class: 'tw:select tw:select-bordered', error_class: 'tw:select-error', valid_class: 'tw:select-success'
  #   end
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end

  # # vertical range
  # config.wrappers :vertical_range, tag: 'fieldset', class: 'tw:fieldset' do |b|
  #   b.use :html5
  #   b.optional :readonly
  #   b.optional :step
  #   b.use :label, class: 'tw:fieldset-legend', error_class: 'tw:text-error'
  #   b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
  #   b.use :input, class: 'range', error_class: 'range-error', valid_class: 'range-success'
  #   b.use :hint, wrap_with: DEFAULT_HINT_WRAP
  # end

  # textarea
  config.wrappers :vertical_textarea, tag: 'fieldset', class: 'tw:fieldset' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.use :label, class: DEFAULT_LABEL_CLASS, error_class: 'tw:text-error'
    b.use :full_error, wrap_with: DEFAULT_ERROR_WRAP
    b.use :input, class: 'tw:textarea tw:w-full'
    b.use :hint, wrap_with: DEFAULT_HINT_WRAP
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
    # date: :vertical_date,
    # datetime: :vertical_datetime,
    # time: :vertical_time,
    # datetime_local: :vertical_datetime_local,
  }
end
