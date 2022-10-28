# frozen_string_literal: true

class WebHookPolicy < ApplicationPolicy
  def test?
    manage?
  end

  def console?
    manage?
  end

  def enable?
    manage?
  end

  def disable?
    manage?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
