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

  task credentials: :environment do
    master_key_path = Rails.root.join('config', 'master.key')
    encryed_file_path = Rails.root.join('config', 'credentials.yml.enc')
    encrypted = Rails.application.encrypted(encryed_file_path)

    if encrypted.key.nil?
      fail [
        "Missing `RAILS_MASTER_KEY` enviroment value and not found file in #{master_key_path}.",
        "Make sure generate one first and store it in a safe place."
      ].join("\n")
    end

    begin
      puts "Preparing encrypted keys: secret_key_base, active_record_encryption ..."
      raw_data = YAML.load(encrypted.read) || {} # Us `encrypted.config` will return keys as symbol`
      raw_data['secret_key_base'] ||= ENV['SECRET_TOKEN'].presence || Rails.application.secret_key_base
      raw_data['active_record_encryption'] ||= {
        'primary_key' => SecureRandom.alphanumeric(32),
        'deterministic_key' => SecureRandom.alphanumeric(32),
        'key_derivation_salt' => SecureRandom.alphanumeric(32),
      }

      Rails.application.encrypted(encryed_file_path).write(YAML.dump(raw_data))
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      puts "Couldn't decrypt #{encryed_file_path}. Perhaps you passed the wrong key?"
    end
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
