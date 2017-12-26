class AddValueToRoles < ActiveRecord::Migration[5.1]
  def up
    add_column :roles, :value, :string, after: :name

    Role.all.each do |role|
      name, value = case role.name
                    when 'admin', '管理员'
                      ['管理员', 'admin']
                    when 'mobile', '移动开发者'
                      ['移动开发者', 'mobile']
                    end
      if name && value
        role.update(name: name, value: value)
      end
    end
  end

  def down
    remove_column :roles, :value
  end
end
