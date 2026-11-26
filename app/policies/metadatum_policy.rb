# frozen_string_literal: true

class MetadatumPolicy < ApplicationPolicy

  def show?
    record_in_org? && user_signed_in_or_guest_mode?
  end

  def new?
    user_signed_in?
  end

  def destroy?
    record_in_org? && user_signed_in? && (owner? || manage?)
  end

  class Scope < Scope
    def resolve
      org_scope
    end
  end

  private

  def record_in_org?
    return true unless org&.respond_to?(:persisted?) && org.persisted? && record.respond_to?(:organization_id)

    record.organization_id.nil? || record.organization_id == org.id
  end

  def owner?
    record.user == user
  end
end
