# frozen_string_literal: true

module SettingSuger
  extend ActiveSupport::Concern

  def readonly?
    self.class.get_field(var.to_sym).try(:[], :readonly) === true
  end

  def default?
    value == default_value
  end

  def default_value
    present[:default]
  end

  def type
    present[:type]
  end

  def validates
    @validates ||= self.class.validators_on(var)
  end

  def present
    @present ||= self.class.get_field(var)
  end

  private

  def mark_restart_flag
    self.class.restart_required!
  end

  def need_restart?
    value_of(var, source: :restart_required) == true
  end

  def convert_third_party_enabled_value
    new_value = value.dup
    new_value['enabled'] = ActiveModel::Type::Boolean.new.cast(value['enabled'])
    self.value = new_value
  end

  def third_party_auth_scope?
    value_of(var, source: :scope) == :third_party_auth
  end

  def value_of(key, source:)
    scope = Setting.defined_fields
                   .select { |s| s[:key] == key }
                   .map { |s| s.respond_to?(source) ? s[source] : s[:options][source] }

    scope.any? ? scope.first : false
  end
end
