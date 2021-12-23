# frozen_string_literal: true

class ChannelPolicy < ApplicationPolicy

  def versions?
    guest_mode_or_signed_in?
  end

  def branches?
    guest_mode_or_signed_in?
  end

  def release_types?
    guest_mode_or_signed_in?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
