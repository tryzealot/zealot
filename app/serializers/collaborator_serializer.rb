# frozen_string_literal: true

class CollaboratorSerializer < ApplicationSerializer
  attributes :id, :username, :email, :role

  def id
    object.user.id
  end

  def username
    object.user.username
  end

  def email
    object.user.email
  end
end
