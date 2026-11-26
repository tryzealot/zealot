# frozen_string_literal: true

class AppPolicy < ApplicationPolicy
  def index?
    user_signed_in_or_guest_mode?
  end

  def show?
    record_in_org? && app_user?
  end

  def create?
    manage?
  end

  def edit?
    record_in_org? && manage?
  end

  def update?
    record_in_org? && manage?
  end

  def destroy?
    record_in_org? && admin?
  end

  def new_owner?
    record_in_org? && admin?
  end

  def update_owner?
    record_in_org? && admin?
  end

  def archive?
    record_in_org? && admin?
  end

  def archived?
    record_in_org? && admin?
  end

  def unarchive?
    record_in_org? && admin?
  end

  class Scope < Scope
    def resolve
      org_scope
    end
  end

  private

  def record_in_org?
    return true unless org&.respond_to?(:persisted?) && org.persisted? && record.respond_to?(:organization_id)

    record.organization_id == org.id
  end

  def app_user?
    return true if guest_mode?
    return true if admin?
    return true if manage?
    return true if effective_role.present? && effective_role != 'guest'

    false
  end
end
