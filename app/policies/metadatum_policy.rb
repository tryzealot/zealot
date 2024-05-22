# frozen_string_literal: true

class MetadatumPolicy < ApplicationPolicy

  def new?
    user_signed_in?
  end

  def destroy?
    user_signed_in?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
