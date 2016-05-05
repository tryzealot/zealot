class AppPolicy < ApplicationPolicy
  def index?
    user.role? [:admin, :mobile]
  end

  def update?
    record.create_id == user.id
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
