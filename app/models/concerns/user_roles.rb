# frozen_string_literal: true

module UserRoles
  extend ActiveSupport::Concern

  included do
    scope :admins, -> { where(role: :admin) }
    scope :developers, -> { where(role: :developer) }
    scope :users, -> { where(role: :user) }
  end

  def manage?(app: nil)
    admin? || developer? || (app && app_roles?(app, :manager))
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

  def app_roles?(app, value)
    value = %w[admin developer] if value.to_sym == :manager
    collaborators.where(app: app, role: value).exists?
  end

  def role_name
    key = if admin?
            :admin
          elsif developer?
            :developer
          else
            :user
          end

    Setting.builtin_roles[key]
  end
end
