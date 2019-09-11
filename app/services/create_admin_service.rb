class CreateAdminService
  def call
    User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
      user.username = '管理员'
      user.password = Rails.application.secrets.admin_password
      user.password_confirmation = Rails.application.secrets.admin_password
      user.actived_at = Time.now

      user.roles << Role.find_by(value: 'admin')
    end
  end
end
