# frozen_string_literal: true

class DebugFilePolicy < ApplicationPolicy

  def download?
    show?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
