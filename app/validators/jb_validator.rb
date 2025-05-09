# frozen_string_literal: true

class JbValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    parsed_value = _parse_jb(record, attribute, value)
    validate_format(record, attribute, parsed_value)
  rescue StandardError
    record.errors.add(attribute, :invaild_jb)
  end

  private

  def _parse_jb(record, attribute, value)
    ApplicationController.render(inline: value.to_s, type: :jb)
  end

  def validate_format(record, attribute, value)
    converted_value = JSON.parse(value)
    record.errors.add(attribute, :invaild_jb) unless converted_value.is_a?(Hash)
  rescue JSON::ParserError
    record.errors.add(attribute, :invaild_jb)
  end

end
