# frozen_string_literal: true

class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    @format = options.fetch(:format, nil)
    @allow_value_empty = ActiveModel::Type::Boolean.new.cast(options.fetch(:value_allow_empty, false))

    super
  end

  def validate_each(record, attribute, value)
    return true if value.blank? && @allow_value_empty

    parsed_value = _json(record, attribute, value)
    validate_value(record, attribute, parsed_value)
    validate_format(record, attribute, parsed_value)

    true
  end

  private

  def validate_value(record, attribute, value)
    record.errors.add(attribute, :empty_json_value) if value.blank?
  end

  def validate_format(record, attribute, value)
    matched = case @format
              when :array
                value.is_a?(Array)
              when :hash
                value.is_a?(Hash)
              end

    record.errors.add(attribute, :incorrect_json_format) unless matched
  end

  def _json(record, attribute, value)
    return value unless value.is_a?(String)

    JSON.parse(value)
  rescue JSON::ParserError
    record.errors.add(attribute, :invaild_json)
  end
end
