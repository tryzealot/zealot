# frozen_string_literal: true

namespace :zealot do
  desc 'Zealot | Upgrade zealot or setting up database'
  task upgrade: :environment do
    Rake::Task['zealot:db:upgrade'].invoke
  end

  namespace :db do
    task upgrade: :environment do
      begin
        db_version = Rake::Task['db:version'].invoke.split(': ').last
        if db_version == '0'
          Rake::Task['zealot:db:setup'].invoke
        else
          Rake::Task['zealot:db:migrate'].invoke
        end
      rescue PG::ConnectionBad, ActiveRecord::NoDatabaseError
        # 无法连接数据库
        Rake::Task['zealot:db:setup'].invoke
      end
    end

    # 初始化
    task setup: :environment do
      puts "Zealot setup database ..."
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:seed'].invoke
    end

    # 升级
    task migrate: :environment do
      puts "Zealot upgrade database ..."
      Rake::Task['db:migrate'].invoke
    end
  end

  task version: :environment do
    require_relative '../setting'

    puts ::Setting.version
  end
end
