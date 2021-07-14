# frozen_string_literal: true

class CreateAdminService
  def call
    User.find_or_create_by!(email: Setting.admin_email) do |user|
      user.username = '管理员'
      user.password = Setting.admin_password
      user.password_confirmation = Setting.admin_password
      user.role = :admin
      user.confirmed_at = Time.current
    end
  end
end
