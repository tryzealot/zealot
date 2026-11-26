# frozen_string_literal: true

class ReleasePolicy < ApplicationPolicy

  def show?
    true
  end

  def new?
    manage?
  end

  def create?
    manage?
  end

  def edit?
    manage?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
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
end
