# frozen_string_literal: true

class CreateAdminService
  def call
    I18n.locale = Setting.site_locale
    return create_demo_mode_users if Setting.demo_mode

    create_user(Setting.admin_email, Setting.admin_password)
  end

  private

  DEMO_LOCALES = {
    en: 'en',
    zh: 'zh-CN'
  }

  def create_demo_mode_users
    users = DEMO_LOCALES.each_with_object([]) do |(prefix, locale), obj|
      email = "#{prefix}_#{Setting.admin_email}"
      user = create_user(email, Setting.admin_password, locale)
      obj << user
    end
  end

  def create_user(email, password, locale = nil)
    User.find_or_create_by!(email: email) do |user|
      user.username = I18n.t('settings.preset_role.admin')
      user.password = password
      user.password_confirmation = password
      user.role = :admin
      user.locale = locale || ENV['DEFAULT_LOCALE']
      user.timezone = ENV['TIME_ZONE'] || 'Asia/Shanghai'
      user.confirmed_at = Time.current
    end
  end
end
