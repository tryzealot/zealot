# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Dump default roles
CreateRolesService.new.call

# Create default admin account
user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email

CreateSampleAppsService.new.call(user)
