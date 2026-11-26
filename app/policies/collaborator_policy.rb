# frozen_string_literal: true

class CollaboratorPolicy < ApplicationPolicy
  def index?
    app_user?
  end

  def show?
    app_user?
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def app
    @app ||= if record.is_a?(Collaborator)
               record.app
             elsif record.respond_to?(:app)
               record.app
             else
               record
             end
  end

  def app_user?
    return true if guest_mode?

    Pundit.policy!(user, app).show?
  end
end
