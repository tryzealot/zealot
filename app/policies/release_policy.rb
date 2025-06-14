# frozen_string_literal: true

class ReleasePolicy < ApplicationPolicy

  def show?
    true
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

  def auth?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def enabled_auth?
    record.channel.password.present?
  end

  def any_manage?
    manage? || manage?(app: app)
  end

  def app
    @app ||= record.app
  end
end
