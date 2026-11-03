# frozen_string_literal: true

module Customize
  extend ActiveSupport::Concern

  def current_locale
    if params[:locale].present?
      validated = vaild_locale(params[:locale])
      return validated if validated
    end

    if current_user&.locale.present?
      validated = vaild_locale(current_user.locale)
      return validated if validated
    end

    if (header_locales = extrace_locale_from_headers)
      header_locales.each do |tag|
        validated = vaild_locale(tag)
        return validated if validated
      end
    end

    vaild_locale(Setting.site_locale) || I18n.default_locale
  end

  def switch_locale(&action)
    I18n.with_locale(current_locale, &action)
  end

  def switch_timezone(&action)
    return yield unless user_signed_in?

    Time.use_zone(current_user.timezone, &action)
  end

  private

  def vaild_locale(locale)
    return if locale.blank?

    target = locale.to_s
    available = I18n.available_locales.map(&:to_s)

    return target.to_sym if available.include?(target)

    prefix = target.split('-').first.downcase
    if prefix == 'zh' && available.include?('zh-CN')
      :'zh-CN'
    elsif available.include?(prefix)
      prefix.to_sym
    end
  end
  alias_method :valid_locale, :vaild_locale

  def extrace_locale_from_headers
    return unless (accept_language = request.env['HTTP_ACCEPT_LANGUAGE'])

    accept_language.split(',').map do |entry|
      tag, *parts = entry.split(';').map(&:strip)
      next if tag.blank?

      q = 1.0
      parts.each do |part|
        q = part[2..].to_f if part.start_with?('q=')
      end

      [tag, q]
    end.compact.sort_by { |_, q| -q }.map(&:first)
  end
  alias_method :extract_locale_from_headers, :extrace_locale_from_headers
end
