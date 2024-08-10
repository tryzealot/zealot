class AddRoleToUsersApps < ActiveRecord::Migration[7.1]
  def up
    add_column :apps_users, :role, :integer, null: false, default: 0

    # all preview apps were created by owner.
    Collaborator.update_all(role: Collaborator.roles[:admin]) if Collaborator.any?
  end

  def down
    remove_column :apps_users, :role
  end
end
