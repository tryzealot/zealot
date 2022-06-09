# frozen_string_literal: true

class MetadatumPolicy < ApplicationPolicy

  def show?
    guest_mode_or_signed_in?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
