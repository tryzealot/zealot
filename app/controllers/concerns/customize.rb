# frozen_string_literal: true

module Customize
  extend ActiveSupport::Concern

  def switch_locale(&action)
    locale = current_user&.locale || Setting.site_locale
    if Setting.demo_mode && !current_user
      locale = extrace_locale_from_headers
    end

    I18n.with_locale(locale, &action)
  end

  def switch_timezone(&action)
    Time.use_zone(current_user.timezone, &action)
  end

  private

  def extrace_locale_from_headers
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
end
