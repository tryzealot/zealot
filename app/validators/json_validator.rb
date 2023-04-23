# frozen_string_literal: true

class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    super
    @allow_empty = ActiveModel::Type::Boolean.new.cast(options.fetch(:allow_empty, false))
  end

  def validate_each(record, attribute, value)
    return if value.blank? && @allow_empty
    return unless value.is_a?(String)

    JSON.parse(value)
  rescue JSON::ParserError
    record.errors.add(attribute, :invaild_json)
  end
end
