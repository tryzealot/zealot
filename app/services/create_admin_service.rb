# frozen_string_literal: true

class CreateAdminService
  def call
    I18n.locale = Setting.site_locale
    create_user(Setting.admin_email, Setting.admin_password)
    create_demo_mode_users if Setting.demo_mode
  end

  private

  DEMO_LOCALES = [
    {
      prefix: 'en',
      locale: 'en',
      timezone: 'Etc/UTC',
    },
    {
      prefix: 'cn',
      locale: 'zh-CN',
      timezone: 'Asia/Shanghai',
    },
  ]

  def create_demo_mode_users
    DEMO_LOCALES.each_with_object([]) do |option, obj|
      email = "#{option[:prefix]}_#{Setting.admin_email}"
      user = create_user(email, Setting.admin_password, option[:locale], option[:timezone])
      obj << user
    end
  end

  def create_user(email, password, locale = nil, timezone = nil)
    User.find_or_create_by!(email: email) do |user|
      user.username = I18n.t('settings.preset_role.admin')
      user.password = password
      user.password_confirmation = password
      user.role = :admin
      user.locale = locale || Setting.site_locale
      user.appearance = 'auto'
      user.timezone = timezone || ENV.fetch('TIME_ZONE', 'Asia/Shanghai')
      user.confirmed_at = Time.current
    end
  end
end
