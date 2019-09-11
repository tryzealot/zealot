class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :name, index: true
      t.string :value, index: true

      t.timestamps
    end
  end
end
