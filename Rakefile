# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
# require 'awesome_print'

Rails.application.load_tasks

task rails_ssl: :environment do
  ENV['ZEALOT_USE_HTTPS'] = 'true'
  system("#{Rails.root}/bin/rails server -p 3000 -e development -b 'ssl://172.16.217.119:3000?key=public/certs/key.pem&cert=public/certs/server.pem'")
end
