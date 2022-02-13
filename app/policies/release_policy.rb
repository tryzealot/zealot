# frozen_string_literal: true

class ReleasePolicy < ApplicationPolicy

  def show?
    true
  end

  def auth?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
