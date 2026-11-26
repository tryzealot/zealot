# frozen_string_literal: true

class ChannelPolicy < ApplicationPolicy
  def index?
    app_user?
  end

  def show?
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

  def destroy_releases?
    manage?
  end

  def versions?
    return true if enabled_auth?

    app_user?
  end

  def branches?
    return true if enabled_auth?

    app_user?
  end

  def release_types?
    return true if enabled_auth?

    app_user?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def enabled_auth?
    record.password.present?
  end

  def app_user?
    user_signed_in_or_guest_mode?
  end
end
