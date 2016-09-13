require 'fileutils'

# USAGE
# =====
# bundle exec rake mobile:backup  RAILS_ENV=production MAX=15 DIR=db/db.bak
# bundle exec rake mobile:restore RAILS_ENV=production BACKUP_FILE=db/db.bak/backup_file.sql.gz
namespace :mobile do
  desc 'Mobile | Create a backup of the Mobile system. Options: DIR=backups RAILS_ENV=production MAX=7'
  task backup: :environment do

    Rake::Task['mobile:db:backup'].invoke
    Rake::Task['mobile:upload:backup'].invoke

    backup = Backup::Manager.new
    backup.pack
    backup.cleanup
    backup.remove_old
  end

  desc 'Mobile | Restore a previously created backup. Options: RAILS_ENV=production BACKUP_FILE=db/db.bak/backup_file.sql.gz'
  task restore: :environment do
    backup = Backup::Manager.new
    backup.unpack

    Rake::Task['mobile:db:restore'].invoke
    Rake::Task['mobile:upload:restore'].invoke

    backup.cleanup
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
