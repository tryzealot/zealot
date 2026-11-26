# frozen_string_literal: true

module AdminHelper
  PROBE_VALUE = 'admin-helper-probe'

  def pretty_json(data)
    new_data = data.each_with_object({}) do |(key, value), obj|
                 obj[key] = secure_value(key, value)
               end

    JSON.pretty_generate(new_data)
  end

  def secure_key?(data)
    return false unless data.is_a?(Hash)

    Setting.demo_mode && data.keys.any? { |key| secure?(key) }
  end

  # Masking used to be gated on `Setting.demo_mode`, which defaults to false, so
  # every ordinary install printed secrets verbatim. Security filtering must not
  # depend on a display preference, so `secure_value` now always masks anything
  # `filter_parameters` marks sensitive. `secure_key?` keeps the demo-mode
  # condition because it also authorizes read-only settings in demo mode.
  def secure_value(key, value)
    secure?(key) ? filtered_token(value) : value
  end

  private

  # Rails 7.1+ replaces `config.filter_parameters` in place with a precompiled
  # array of combined Regexps the first time `Rails.application.filter_parameters`
  # is called, so the previous `key.include?(entry.to_s)` test never matched and
  # this page printed every secret verbatim. Probing with an actual
  # ParameterFilter works for both shapes instead of assuming one.
  def secure?(key)
    # Check if the key is blank or matches a specific value
    return false if key.blank? || key == 'token_expiry_in_minutes'

    name = key.to_s
    filtered = parameter_filter.filter(name => PROBE_VALUE)
    filtered[name] != PROBE_VALUE
  end

  def parameter_filter
    @parameter_filter ||= ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters
    )
  end

  def filtered_token(chars)
    chars = chars.to_s
    return '*' * chars.size if chars.size < 4

    average = chars.size / 4
    prefix = chars[0..average - 1]
    hidden = '*' * (average * 2)
    suffix = chars[(prefix.size + average * 2)..-1]
    "#{prefix}#{hidden}#{suffix}"
  end
end
