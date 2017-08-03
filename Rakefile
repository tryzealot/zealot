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

  task pwd: :environment do
    accounts.each do |key, _|
      account_password_variable_name = "#{key.upcase}_PASSWORD"
      print "#{account_password_variable_name} => "
      puts ENV[account_password_variable_name]
    end
  end

  def accounts
    {
      qyer_inc: {
        user: 'yi.xiao@go2eu.com',
        team_id: '5PJA6N5A3B'
      },
      qyer_co_ltd: {
        user: 'enterpriseidp@qq.com'
      },
      qyer_inhouse: {
        user: 'enterprisetest@qq.com'
      }
    }
  end
end
