class AddValueToRoles < ActiveRecord::Migration[5.1]
  def change
    add_column :roles, :value, :string, after: :name
  end
end
