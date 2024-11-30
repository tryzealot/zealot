# frozen_string_literal: true

require_relative '../../zealot/smtp_validator'

namespace :zealot do
  desc 'Zealot | Upgrade zealot or setting up database'
  task upgrade: :environment do
    Rake::Task['zealot:version'].invoke
    Rake::Task['zealot:db:upgrade'].invoke
  end

  desc 'Zealot | Precheck service healthly'
  task precheck: :environment do
    Rake::Task['zealot:check:smtp'].invoke
  end

  desc 'Zealot | Remove all data and init demo data and user'
  task reset: :environment do
    ResetForDemoModeJob.perform_now
  end

  namespace :check do
    task smtp: :environment do
      puts "SMTP testing ..."

      smtp_validator = Zealot::SmtpValidator.new
      if smtp_validator.configured?
        success = smtp_validator.verify
        unless success
          fail smtp_validator.error_message
          exit!
        end
        puts "SMTP verified successful"
      else
        puts "SMTP is not configure, skip"
      end
    end
  end

  namespace :db do
    task upgrade: :environment do
      db_version = begin
                     ActiveRecord::Migrator.current_version
                   rescue ActiveRecord::NoDatabaseError
                     nil
                   end

      if db_version.blank? || db_version.zero?
        Rake::Task['zealot:db:setup'].invoke
      else
        Rake::Task['zealot:db:migrate'].invoke(db_version)
      end
    end

    # 初始化
    task setup: :environment do
      puts "Zealot initialize database ..."
      system("rails db:create")
      system("rails db:migrate")

      puts "Zealot initialize admin user and sample data ..."
      system("rails db:seed")
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
    message = message.present? ? " (#{message})" : nil
    docker = (docker_tag = ENV['DOCKER_TAG']).present? ? " [docker:#{docker_tag}]" : nil

    puts "Zealot version: #{version}#{message}#{docker}"
  end

  desc "Zealot | generate swagger files"
  task swaggerize: :environment do
    current_locale = ENV['DEFAULT_LOCALE']

    Rails.configuration.i18n.available_locales.sort.each do |locale|
      puts "Generating swagger file ... #{locale}"
      system("DEFAULT_LOCALE=#{locale} rails rswag:specs:swaggerize 2>&1 > /dev/null")
    end

    # restore
    ENV['DEFAULT_LOCALE'] = current_locale
  end
end