# frozen_string_literal: true

class ChannelPolicy < ApplicationPolicy

  def versions?
    true
  end

  def branches?
    true
  end

  def release_types?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
