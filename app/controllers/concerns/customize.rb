# frozen_string_literal: true

module Customize
  extend ActiveSupport::Concern

  def switch_locale(&action)
    locale = current_user&.locale
    if Setting.demo_mode && !current_user
      locale = extrace_locale_from_headers
    end
    locale ||= Setting.site_locale

    I18n.with_locale(locale, &action)
  end

  def switch_timezone(&action)
    return yield unless user_signed_in?

    Time.use_zone(current_user.timezone, &action)
  end

  private

  def extrace_locale_from_headers
    return unless accept_language = request.env['HTTP_ACCEPT_LANGUAGE']

    accept_language.scan(/^[a-z]{2}/)&.first
  end
end
