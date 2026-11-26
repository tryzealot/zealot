class AddRoleToUsersApps < ActiveRecord::Migration[7.1]
  class Collaborator < ActiveRecord::Base
    self.table_name = "apps_users"
  end

  ADMIN_ROLE = 2

  def change
    add_column :apps_users, :role, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Collaborator.update_all(role: ADMIN_ROLE) if Collaborator.exists?
      end
    end
  end
end
