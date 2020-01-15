require_relative '../backup/manager'
require_relative '../backup/database'
require_relative '../backup/upload'
require 'fileutils'

# USAGE
# =====
# bundle exec rake zealot:backup  RAILS_ENV=production MAX=15 DIR=db/db.bak
# bundle exec rake zealot:restore RAILS_ENV=production BACKUP_FILE=db/db.bak/backup_file.sql.gz
namespace :zealot do
  desc 'Zealot | Create a backup of the Zealot. Options: DIR=backups RAILS_ENV=production MAX=7'
  task backup: :environment do
    Rake::Task['zealot:db:backup'].invoke
    Rake::Task['zealot:upload:backup'].invoke

    backup = Backup::Manager.new
    backup.pack
    backup.cleanup
    backup.remove_old
  end

  desc 'Zealot | Restore a previously created backup. Options: RAILS_ENV=production BACKUP=backup_file.tar'
  task restore: :environment do
    backup = Backup::Manager.new

    unless File.exist?(backup.db_backup_file_path)
      backup.unpack
    else
      puts 'Found and using previously database file.'
    end

    warning = <<-MSG.strip_heredoc
      Before restoring the database we recommend removing all existing tables
      to avoid future upgrade problems. Be aware that if you have custom tables
      in the GitLab database these tables and all data will be removed.
    MSG

    puts warning
    ask_to_continue
    puts 'Removing all tables. Press `Ctrl-C` within 5 seconds to abort'
    sleep(5)

    print 'Cleaning the database ... '
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    puts '[DONE]'

    Rake::Task['zealot:db:restore'].invoke

    unless File.exist?(backup.apps_backup_path)
      puts 'No apps found, automitac clean old data ...'
      puts 'Please try again'

      backup.cleanup
      exit 1
    end

    Rake::Task['zealot:upload:restore'].invoke
    backup.cleanup
  end

  desc 'Zealot | List backups files'
  task list_backups: :environment do
    backup = Backup::Manager.new
    files_list = backup.backups_list

    if files_list.count.zero?
      puts 'No backups found'
      exit 1
    end

    puts "Zealot backups found (#{files_list.count}):\n\n"
    files_list.each do |f|
      puts " * #{f}"
    end
  end

  namespace :db do
    task backup: :environment do
      Backup::Database.new.dump
    end

    task restore: :environment do
      Backup::Database.new.restore
    end
  end

  namespace :upload do
    task backup: :environment do
      Backup::Upload.new.dump
    end

    task restore: :environment do
      Backup::Upload.new.restore
    end
  end
end

def prompt(*args)
  print(*args)
  STDIN.gets.strip
end

def ask_to_continue
  answer = prompt('Do you want to continue (yes/no)? ')
  case answer
  when 'no', 'NO', 'n'
    exit 1
  when 'yes', 'YES', 'y'
    # Nothing
  else
    puts 'Please enter yes or no, try again.'
    ask_to_continue
  end
end
