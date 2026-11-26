# frozen_string_literal: true

class SchemePolicy < ApplicationPolicy
  def index?
    app_user?
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

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def app_user?
    user_signed_in_or_guest_mode?
  end
end
