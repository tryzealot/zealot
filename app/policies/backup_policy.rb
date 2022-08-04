# frozen_string_literal: true

class BackupPolicy < ApplicationPolicy

  def perform?
    admin?
  end

  def download?
    admin?
  end

  def enable?
    admin?
  end

  def disable?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
