# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
# require 'awesome_print'

Rails.application.load_tasks

namespace :test do
  task release: :environment do
    # c = Channel.take
    # r = c.releases.new
    # r.bundle_id = 'ss'
    # r.release_version = '33'
    # r.build_version = '32'
    # r.changelog = "adfadf\nasdfasdf\n"
    # r.save validate:false

    r = Release.take
    r.changelog = [ { message: 'dddd' } ].to_json
    r.save validate: false
  end

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
