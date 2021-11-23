# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    guest_mode_or_signed_in?
  end

  def show?
    scope.where(id: record.id).exists? || Setting.guest_mode || user?
  end

  def create?
    manage?
  end

  def new?
    manage?
  end

  def update?
    manage?
  end

  def edit?
    manage?
  end

  def destroy?
    manage?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  delegate :admin?, :developer?, :manage?, :user?, to: :user, allow_nil: true

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  protected

  def demo_mode?
    Setting.demo_mode == true
  end

  def guest_mode_or_signed_in?
    Setting.guest_mode || user_signed_in?
  end

  def user_signed_in?
    user.present?
  end
end
