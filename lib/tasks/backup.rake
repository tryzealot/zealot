require 'fileutils'

# USAGE
# =====
# bundle exec rake mobile:backup  RAILS_ENV=production MAX=15 DIR=db/db.bak
# bundle exec rake mobile:restore RAILS_ENV=production BACKUP_FILE=db/db.bak/backup_file.sql.gz
namespace :mobile do
  desc 'Mobile | Create a backup of the Mobile system. Options: DIR=backups RAILS_ENV=production MAX=7'
  task backup: :environment do

    Rake::Task['mobile:db:backup'].invoke
    Rake::Task['mobile:app:backup'].invoke

    manager = Backup::Manager.new
    manager.pack
    manager.cleanup
    manager.remove_old
  end

  desc 'Mobile | Restore a previously created backup. Options: RAILS_ENV=production BACKUP_FILE=db/db.bak/backup_file.sql.gz'
  task restore: :environment do
  end

  namespace :db do
    task backup: :environment do
      Backup::Database.new.dump
    end

    task restore: :environment do

    end
  end

  namespace :app do
    task backup: :environment do
      Backup::App.new.dump
    end

    task restore: :environment do

    end
  end
end
