# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :org, :record

  def initialize(user, record)
    # user may be a context (Struct with :user, :org) from pundit_user or a raw user
    @user = user.respond_to?(:user) ? user.user : user
    @org  = (user.respond_to?(:org) && user.org) || Current.organization
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

  def admin?
    effective_role == 'admin' || effective_role == 'owner'
  end

  def developer?
    effective_role == 'developer'
  end

  def member?
    effective_role == 'member'
  end

  def manage?(*)
    admin? || developer?
  end

  delegate :guest?, to: :user, allow_nil: true

  class Scope
    attr_reader :user, :org, :scope

    def initialize(user, scope)
      @user = user.respond_to?(:user) ? user.user : user
      @org  = (user.respond_to?(:org) && user.org) || Current.organization
      @scope = scope
    end

    def resolve
      scope.all
    end

    protected

    def org_scope
      return scope unless scope.respond_to?(:where)
      return scope unless org&.respond_to?(:id) && org.respond_to?(:persisted?) && org.persisted?

      model = scope.respond_to?(:klass) ? scope.klass : scope
      if model.respond_to?(:column_names) && model.column_names.include?('organization_id')
        scope.where(organization_id: org.id)
      else
        scope
      end
    end
  end

  protected

  # The role in effect for this request. Delegates to the deep RoleResolver
  # to synthesize System Admin, Organization Role, and App Collaborator.
  def effective_role
    Zealot::Resolvers::RoleResolver.resolve(
      user: user,
      record: record,
      organization: org
    )
  end

  def user_signed_in_or_guest_mode?
    user.present?
  end

  def guest_mode?
    return false if Zealot::Resolvers::RoleResolver.multi_org_enabled? && !Zealot::Resolvers::RoleResolver.default_org?(org)

    Setting.guest_mode
  end

  def user_signed_in?
    user.present? && !user.try(:guest?)
  end
end
