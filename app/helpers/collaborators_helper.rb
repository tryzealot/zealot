# frozen_string_literal: true

module CollaboratorsHelper
  def not_same_user?(collaborator)
    collaborator.user != current_user
  end

  def edit_role_user?(collaborator)
    target_role = collaborator.role
    if current_user.manage?
      return User.roles[target_role] < Collaborator.roles[current_user.role]
    end

    source_role = Collaborator.find_by(user: current_user, app: collaborator.app).role
    Collaborator.roles[target_role] < Collaborator.roles[source_role]
  end
end
