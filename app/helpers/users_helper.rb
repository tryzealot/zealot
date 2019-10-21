# frozen_string_literal: true

module UsersHelper
  def roles
    User.roles.to_a.collect{|c| [User::ROLE_NAMES[c[0].to_sym], c[0]]}
  end
end
