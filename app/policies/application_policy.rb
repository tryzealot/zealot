# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user_signed_in_or_guest_mode?
  end

  def show?
    scope.where(id: record.id).exists? || user_signed_in_or_guest_mode?
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

  delegate :admin?, :developer?, :manage?, :member?, to: :user, allow_nil: true

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

  def app_collaborator?(user, app, role: nil, exclude: false)
    model = Collaborator.where(user: user, app: app)
    return model.exists? unless role
    
    exclude ? model.where.not(role: role).exists? : model.where(role: role).exists?
  end

  def user_signed_in_or_guest_mode?
    guest_mode? || user_signed_in?
  end

  def guest_mode?
    Setting.guest_mode
  end

  def user_signed_in?
    user.present?
  end
end
