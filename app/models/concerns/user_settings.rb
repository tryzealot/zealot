# frozen_string_literal: true

module UserSettings
  extend ActiveSupport::Concern

  class_methods do
    def enum_roles
      @enum_roles ||= Rails.configuration.i18n.available_locales.each_with_object({}) {|v,o| o[v] = v.to_s }
    end

    def options_roles
      Rails.configuration.i18n.available_locales.each_with_object({}) do |v, obj|
        obj[v] = I18n.t("settings.site_locale.#{v}")
      end
    end

    def enum_appearances
      Setting.builtin_appearances
    end

    def options_appearances
      enum_appearances
    end

    def enum_timezones
      ActiveSupport::TimeZone.all.each_with_object({}) do |timezone, obj|
        key = timezone.tzinfo.name
        obj[key] = key
      end
    end

    def options_timezones
      ActiveSupport::TimeZone.all.each_with_object({}) do |timezone, obj|
        key = timezone.tzinfo.name
        value = timezone.to_s
        obj[key] = value
      end.sort_by { |k,v| v }
    end
  end
end
