class CreateAdminService
  def call
    User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
      user.name = 'Administrator'
      user.password = Rails.application.secrets.admin_password
      user.password_confirmation = Rails.application.secrets.admin_password
      user.roles << Role.find_by(name: 'admin')
    end
  end
end
