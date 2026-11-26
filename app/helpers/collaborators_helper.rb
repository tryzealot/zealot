# frozen_string_literal: true

module CollaboratorsHelper
  def same_user?(collaborator)
    collaborator.user == current_user
  end

  def edit_role_user?(collaborator)
    policy(collaborator).edit?
  end
end
