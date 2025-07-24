# frozen_string_literal: true

class MetadatumPolicy < ApplicationPolicy

  def show?
    user_signed_in_or_guest_mode? || (user_signed_in? && (owner? || any_manage? || app_member?))
  end

  def new?
    user_signed_in?
  end

  def destroy?
    user_signed_in? && (owner? || any_manage? || app_member?)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def any_manage?
    return true if manage?
    return false unless app = record.app

    manage?(app: app)
  end

  def app_member?
    return false unless app = record.app

    app_collaborator?(user, app)
  end

  def owner?
    record.user == user
  end
end
