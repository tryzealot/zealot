# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create default admin account
user = CreateAdminService.new.call
if user.is_a?(Array)
  puts 'CREATED ADMIN USERS: ' << user.map {|u| u.email }.join(', ')
else
  puts 'CREATED ADMIN USER: ' << user.email
end

skip_sample_data = ActiveModel::Type::Boolean.new.cast(ENV['ZEALOT_SKIP_SAMPLE_DATE'] || false)
unless skip_sample_data
  CreateSampleDataService.new.call(user)
  puts 'CREATED EXAMPLE APPS DATA'
end
