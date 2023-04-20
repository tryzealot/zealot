# frozen_string_literal: true

module SettingValidate
  extend ActiveSupport::Concern

  include ActionView::Helpers::TranslationHelper

  def field_validates
    validates.each_with_object([]) do |validate, obj|
      next unless value = validate_value(validate)

      obj << value
    end
  end

  def inclusion?
    inclusions = validates.select {|v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
    inclusions&.first
  end

  def inclusion_values
    return unless inclusion = inclusion?

    delimiters = inclusion.send(:delimiter)
    delimiters = delimiters.call if delimiters.respond_to?(:call)
    delimiters.each_with_object({}) do |value, obj|
      key = t("settings.#{var}.#{value}", default: value)
      obj[key] = value
    end
  end

  private

  def validate_value(validate)
    case validate
    when ActiveModel::Validations::PresenceValidator
      t('errors.messages.blank')
    when ActiveRecord::Validations::LengthValidator
      minimum = validate.options[:minimum]
      maximum = validate.options[:maximum]
      t('errors.messages.length_range', minimum: minimum, maximum: maximum)
    when ActiveModel::Validations::InclusionValidator
      t('errors.messages.optional_value', value: inclusion_values.values.join(', '))
    when ActiveRecord::Validations::NumericalityValidator
      t('errors.messages.only_integer') if validate.options[:only_integer]
    when JsonValidator
      t('errors.messages.json_format')
    end
  end
end
