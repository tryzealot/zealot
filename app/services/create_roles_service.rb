class CreateRolesService
  def call
    roles = [
      {
        name: '用户',
        value: 'user'
      },
      {
        name: '管理员',
        value: 'admin'
      }
    ]

    roles.each do |role|
      Role.find_or_create_by!(name: role[:name], value: role[:value])
    end
  end
end
