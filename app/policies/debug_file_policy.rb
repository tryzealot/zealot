# frozen_string_literal: true

class DebugFilePolicy < ApplicationPolicy

  def index?
    app_user?
  end

  def new?
    app_manage?
  end

  def create?
    app_manage?
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

  def reprocess?
    any_manage?
  end

  def device?
    app_user?
  end

  def download?
    show?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def app_user?
    guest_mode? || any_manage? || app_collaborator?(user, app)
  end

  def any_manage?
    manage? || (app && manage?(app: app))
  end

  def app_manage?
    any_manage? || app_collaborator?(user, user.apps.map(&:id))
  end

  def app
    @app ||= record.app
  end
end
