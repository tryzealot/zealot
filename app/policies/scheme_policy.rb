# frozen_string_literal: true

class SchemePolicy < ApplicationPolicy

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

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def app_user?
    any_manage? || app_collaborator?(user, record.app)
  end

  def any_manage?
    manage? || manage?(app: record.app)
  end
end
