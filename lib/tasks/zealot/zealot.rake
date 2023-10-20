# frozen_string_literal: true

namespace :zealot do
  MIN_REDIS_VERSION = '6.2'

  desc 'Zealot | Upgrade zealot or setting up database'
  task upgrade: :environment do
    Rake::Task['zealot:version'].invoke
    Rake::Task['zealot:db:upgrade'].invoke
  end

  desc 'Zealot | Precheck service healthly'
  task precheck: :environment do
    redis_version = Rails.cache.stats['redis_version']
    if Gem::Version.new(redis_version) < Gem::Version.new(MIN_REDIS_VERSION)
      raise "[ERROR] Redis server version requires 6.2+, current version is #{redis_version}."
    end
  rescue Redis::CannotConnectError
    raise "[ERROR] Redis server can not connected."
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
        puts "[WARNNING] Found zealot ran the previous version, database must rollback !!!"
        puts "File version (#{file_version_str}) < Database version (#{args.version})"
      else
        puts "Zealot upgrade database ..."
        Rake::Task['db:migrate'].invoke
      end
    end
  end

  desc 'Zealot | Print version'
  task version: :environment do
    version = Setting.version
    version = "#{version}-dev" if Rails.env.development?

    message = ''
    if build_date = Setting.build_date
      message += "#{build_date} "
    end

    if vcs = Setting.vcs_ref
      message += "revision #{vcs[0..7]}"
    end
    message = message ? " (#{message})" : nil
    docker = (docker_tag = ENV['DOCKER_TAG']) ? " [docker:#{docker_tag}]" : nil

    puts "Zealot #{version}#{message}#{docker}"
  end
end
