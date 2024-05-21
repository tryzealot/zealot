# frozen_string_literal: true

module Locale
  extend ActiveSupport::Concern

  def set_locale
    I18n.locale = Setting.site_locale
  end
end
