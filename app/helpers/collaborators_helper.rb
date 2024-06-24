# frozen_string_literal: true

module CollaboratorsHelper
  def same_user?(collaborator)
    collaborator.user == current_user
  end

  def edit_role_user?(collaborator)
    return true if current_user.admin?
    return true if current_user.app_roles?(collaborator.app, :admin)

    false
  end
end
