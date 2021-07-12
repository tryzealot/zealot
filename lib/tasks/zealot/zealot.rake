# frozen_string_literal: true

namespace :zealot do
  desc 'Zealot | Upgrade zealot or setting up database'
  task upgrade: :environment do
    Rake::Task['zealot:db:upgrade'].invoke
  end

  desc 'Zealot | Remove all data and init demo data and user'
  task reset: :environment do
    ResetForDemoModeJob.perform_now
  end

  namespace :db do
    task upgrade: :environment do
      db_version = ActiveRecord::Migrator.current_version
      if db_version.blank?
        Rake::Task['zealot:db:setup'].invoke
      else
        Rake::Task['zealot:db:migrate'].invoke
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
    puts Setting.version
  end
end
