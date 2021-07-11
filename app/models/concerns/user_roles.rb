# frozen_string_literal: true

module UserRoles
  extend ActiveSupport::Concern

  ROLE_NAMES = {
    user: '用户',
    developer: '开发者',
    admin: '管理员'
  }

  included do
    scope :admins, -> { where(role: :admin) }
    scope :developers, -> { where(role: :developer) }
    scope :users, -> { where(role: :user) }
  end

  def manage?
    admin? || developer?
  end

  def grant_admin!
    update!(role: :admin)
  end

  def revoke_admin!
    update!(role: :user)
  end

  def grant_developer!
    update!(role: :developer)
  end

  def revoke_developer!
    update!(role: :user)
  end

  def roles?(value)
    roles.where(role: value.to_sym).exists?
  end

  def role_name
    if admin?
      '管理员'
    elsif developer?
      '开发者'
    else
      '用户'
    end
  end
end
