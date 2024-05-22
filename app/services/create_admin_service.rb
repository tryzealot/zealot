# frozen_string_literal: true

class CreateAdminService
  include ActionView::Helpers::TranslationHelper

  def call
    return create_demo_mode_users if Setting.demo_mode

    User.find_or_create_by!(email: Setting.admin_email) do |user|
      user.username = t('settings.preset_role.admin')
      user.password = Setting.admin_password
      user.password_confirmation = Setting.admin_password
      user.role = :admin
      user.confirmed_at = Time.current
    end
  end

  private

  def create_demo_mode_users
    ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_DEMO_MODE'] || false)
  end
end
