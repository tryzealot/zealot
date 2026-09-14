# frozen_string_literal: true

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
        if success
          puts "SMTP verified successful"
        else
          puts "SMTP verified fail: #{smtp_validator.error_message}"
        end
      else
        puts "SMTP is not configure, skip"
      end
    end
  end

  namespace :db do
    task upgrade: :environment do
      context = ActiveRecord::MigrationContext.new(Rails.application.config.paths['db/migrate'].to_a)
      db_version = begin
                     context.current_version
                   rescue ActiveRecord::NoDatabaseError
                     nil
                   end

      if db_version.blank? || db_version.zero?
        Rake::Task['zealot:db:setup'].invoke
      else
        Rake::Task['zealot:db:migrate'].invoke
      end
    end

    # 初始化
    task setup: :environment do
      puts "Zealot initialize database ..."
      system("rails db:create")
      system("rails db:migrate")

      # NOTE: wait db migrate then insert data
      sleep 3

      puts "Zealot initialize admin user and sample data ..."
      system("rails db:seed")
    end

    # 升级
    task migrate: :environment do
      migration_paths = Rails.application.config.paths['db/migrate'].to_a
      context = ActiveRecord::MigrationContext.new(migration_paths)

      max_file_version = context.migrations.map(&:version).max || 0
      current_version = context.current_version

      if current_version > max_file_version
        puts "[WARNING] Found zealot ran the previous version, database must rollback !!!"
        puts "File version (#{max_file_version}) < Database version (#{current_version})"
      elsif context.needs_migration?
        pending_count = context.pending_migration_versions.size
        puts "Zealot upgrade database (#{pending_count} pending migrations) ..."
        Rake::Task['db:migrate'].invoke
      else
        puts "Zealot database is up to date: #{current_version}"
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
    locale_remapping = {
      "zh-CN" => "zh-Hans",
    }

    system("mkdir -p tmp/docs")
    Rails.configuration.i18n.available_locales.sort.each do |locale|
      puts "Generating swagger file ... #{locale}"
      system("DEFAULT_LOCALE=#{locale} rails rswag:specs:swaggerize 2>&1 > /dev/null")
      # generate files for docs use
      output_file = "openapi_v1_#{locale_remapping[locale.to_s] || locale}.json"
      system("cp -f swagger/v1/swagger_#{locale}.json tmp/docs/#{output_file}")
    end

    # restore
    ENV['DEFAULT_LOCALE'] = current_locale
  end
end
