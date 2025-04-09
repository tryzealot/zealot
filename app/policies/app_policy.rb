# frozen_string_literal: true

class AppPolicy < ApplicationPolicy
  def index?
    app_user?
  end

  def show?
    app_user?
  end

  def create?
    any_manage?
  end

  def edit?
    any_manage?
  end

  def update?
    any_manage?
  end

  def destroy?
    any_manage?
  end

  def new_owner?
    admin? || app_owner?
  end

  def update_owner?
    admin?|| app_owner?
  end

  def archive?
    admin? || manage?
  end

  def unarchive?
    admin? || manage?
  end

  def archived?
    admin? || manage?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def app_user?
    guest_mode? || any_manage? || app_collaborator?(user, record)
  end

  def any_manage?
    manage? || manage?(app: record)
  end

  def app_owner?
    Collaborator.where(user: user, app: record, role: 'admin', owner: true).exists?
  end
end
