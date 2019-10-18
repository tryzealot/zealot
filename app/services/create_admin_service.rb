class CreateAdminService
  def call
    User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
      user.username = '管理员'
      user.password = Rails.application.secrets.admin_password
      user.password_confirmation = Rails.application.secrets.admin_password
      user.confirmed_at = Time.now

      Role.all.each do |role|
        user.roles << role unless user.roles.exists?(role.id)
      end
    end
  end
end
