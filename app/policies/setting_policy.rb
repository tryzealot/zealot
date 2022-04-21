# frozen_string_literal: true

class SettingPolicy < ApplicationPolicy
  def show?
    admin?
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def update?
    admin?
  end

  def edit?
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
end
