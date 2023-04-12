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
      if db_version.blank? || db_version.zero?
        Rake::Task['zealot:db:setup'].invoke
      else
        Rake::Task['zealot:db:migrate'].invoke(db_version)
      end
    end

    # 初始化
    task setup: ['db:create',] do
      puts "Zealot initialize database ..."
      Rake::Task['db:setup'].invoke # need db/schema.rb
      Rake::Task['db:migrate:status'].invoke
    end

    # 升级
    task :migrate, %i[version] => :environment do |_, args|
      file_version_str = Dir.children(Rails.root.join('db', 'migrate'))
                           .map { |f| File.basename(f).split('_')[0] }
                           .max
      file_version = Time.parse(file_version_str)
      db_version = Time.parse(args.version.to_s)

      if file_version == db_version
        puts "Zealot database is up to date: #{file_version_str}"
        next
      end

      if file_version < db_version
        puts "!!!Found zealot ran the previous version, database must rollback!!!"
        puts "File version (#{file_version_str}) < Database version (#{args.version})"
      else
        puts "Zealot upgrade database ..."
        Rake::Task['db:migrate'].invoke
      end
    end
  end

  desc 'Zealot | Print version'
  task version: :environment do
    puts Setting.version
  end
end
