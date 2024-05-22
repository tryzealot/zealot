# frozen_string_literal: true

class DebugFilePolicy < ApplicationPolicy

  def index?
    app_user?
  end

  def new?
    any_manage?
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
    guest_mode? || any_manage? || Collaborator.where(user: user, app: app).exists?
  end

  def any_manage?
    manage? || manage?(app: app)
  end

  def app
    @app ||= record.app
  end
end
