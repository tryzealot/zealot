# frozen_string_literal: true

module ReleaseAuth
  extend ActiveSupport::Concern

  COOKIE_KEY_PREFIX = 'zealot_app_channel_auth_'

  def cookie_password_matched?(cookies)
    channel.password.blank? || cookies[cache_key] == channel.encode_password
  end

  def password_match?(cookies, password)
    if channel.password == password
      store_cookie_auth(cookies)
      return true
    end

    false
  end

  private

  def store_cookie_auth(cookies)
    cookies[cache_key] = channel.encode_password
  end

  def cache_key
    @cache_key ||= "#{COOKIE_KEY_PREFIX}#{channel.id}"
  end
end
