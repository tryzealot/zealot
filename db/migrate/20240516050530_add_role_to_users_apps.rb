class AddRoleToUsersApps < ActiveRecord::Migration[7.1]
  def change
    add_column :apps_users, :role, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Collaborator.update_all(role: Collaborator.roles[:admin]) if Collaborator.any?
      end
    end
  end
end
