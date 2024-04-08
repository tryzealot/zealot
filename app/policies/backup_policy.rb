# frozen_string_literal: true

class BackupPolicy < ApplicationPolicy

  def perform?
    admin?
  end

  def enable?
    admin?
  end

  def disable?
    admin?
  end

  def download_archive?
    admin?
  end

  def destroy_archive?
    admin?
  end

  def cancel_job?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
