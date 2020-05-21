# frozen_string_literal: true

class Download::DebugFilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
