# frozen_string_literal: true

module UserRoles
  extend ActiveSupport::Concern

  def admin?
    roles? 'admin'
  end

  def user?
    roles? 'user'
  end

  def grant_admin!
    set_role('admin', true)
  end

  def revoke_admin!
    set_role('admin', false)
  end

  def current_roles
    roles.all.map(&:name).join('/')
  end

  def grant_roles(id)
    return unless role = Role.find(id)

    default_role = Role.default_role
    if default_role.id == role.id
      roles << role
    else
      roles << Role.default_role << role
    end
  end

  def roles?(*values)
    roles.where(value: values).exists?
  end

  def set_role(role_value, value)
    role = Role.find_by(value: role_value)
    return if (value && role) || (!value && !role)

    if value
      roles << role
    else
      roles.destroy(role)
    end
  end
end
