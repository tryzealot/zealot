# frozen_string_literal: true

namespace :zealot do
  desc 'Zealot | Upgrade zealot or setting up database'
  task upgrade: :environment do
    Rake::Task['zealot:upgrade_db'].invoke
  end

  task upgrade_db: :environment do
    db_version = Rake::Task['db:version'].invoke.split(': ').last
    if db_version == '0'
      # 初始化
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:seed'].invoke
    else
      # 升级
      Rake::Task['db:migrate'].invoke
    end
  end

  task version: :environment do
    require_relative '../setting'

    puts ::Setting.version
  end
end
