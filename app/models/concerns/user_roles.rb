module UserRoles
  extend ActiveSupport::Concern

  def admin?
    roles? 'admin'
  end

  def roles?(*values)
    roles.where(value: values).exists?
  end
end