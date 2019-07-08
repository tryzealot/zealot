class CreateRolesService
  def call
    roles = [
      {
        name: 'User',
        value: 'user'
      },
      {
        name: 'Administrator',
        value: 'admin'
      }
    ]

    roles.each do |role|
      Role.find_or_create_by!(name: role[:name], value: role[:description])
    end
  end
end
