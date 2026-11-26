# frozen_string_literal: true

class GuestUser
  def id
    nil
  end

  def persisted?
    false
  end

  def new_record?
    true
  end

  def username
    I18n.t('zealot.guest', default: 'Guest')
  end

  def email
    ''
  end

  def token
    nil
  end

  def role
    'guest'
  end

  def role_name
    I18n.t('zealot.guest', default: 'Guest')
  end

  def guest?
    true
  end

  def signed_in?
    false
  end

  def admin?
    false
  end

  def developer?
    false
  end

  def member?
    false
  end

  def manage?(*)
    false
  end

  def organizations
    [::Organization.new]
  end

  def locale
    Setting.site_locale
  end

  def appearance
    Setting.site_appearance
  end

  def timezone
    Setting.site_timezone
  end

  def light_theme
    'light'
  end

  def dark_theme
    'dark'
  end

  def access_locked?
    false
  end

  def confirmed?
    false
  end

  def present?
    true
  end

  def blank?
    false
  end
end
