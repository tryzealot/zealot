# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
# require 'awesome_print'

Rails.application.load_tasks

namespace :test do
  task env: :environment do
    ENV.each do |k, v|
      puts "#{k} = #{v}"
    end
  end

  task smtp: :environment do
    require 'net/smtp'
    begin
      email = ''
      password = ''
      smtp = Net::SMTP.new('mail.example.com', 25)
      smtp.start('no-reply@example.com', email, password, 'plain')
      ap smtp.started?
    rescue Net::SMTPAuthenticationError
      puts 'user or password is wrong'
    end
  end
end
