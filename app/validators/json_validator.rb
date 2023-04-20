# frozen_string_literal: true

class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    JSON.parse(value)
  rescue JSON::ParserError
    record.errors.add(attribute, :invaild_json)
  end
end
