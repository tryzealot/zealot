# frozen_string_literal: true

class JbValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_format(record, attribute, value)
  rescue StandardError
    record.errors.add(attribute, :invaild_jb)
  end

  private

  def validate_format(record, attribute, value)
    interpolated = WebHookService::PayloadBuilder.interpolate(
      value.to_s,
      WebHookService::PayloadBuilder.mock_context
    )
    parsed = JSON.parse(interpolated)
    record.errors.add(attribute, :invaild_jb) unless parsed.is_a?(Hash)
  rescue StandardError
    record.errors.add(attribute, :invaild_jb)
  end
end
