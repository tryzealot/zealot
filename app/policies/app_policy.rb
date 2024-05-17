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

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def app_user?
    guest_mode? || any_manage? || Collaborator.where(user: user, app: record).exists?
  end

  def any_manage?
    manage? || manage?(app: record)
  end
end
