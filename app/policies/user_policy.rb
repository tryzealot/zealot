# frozen_string_literal: true

class UserPolicy < ApplicationPolicy

  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def me?
    user_signed_in?
  end

  def search?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
