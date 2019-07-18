module Backup
  module Config
    def backup_path
      File.join(Rails.root, 'tmp', 'backups')
    end

    def db_config
      ActiveRecord::Base.connection_config
    end

    def db_backup_path
      File.join(backup_path, 'db')
    end

    def db_backup_file_path
      File.join(db_backup_path, 'database.sql.gz')
    end

    def app_uploads_path
      File.join(Rails.root, 'public', 'uploads')
    end

    def apps_stored_path
      File.join(app_uploads_path, 'apps')
    end

    def apps_backup_path
      File.join(backup_path, 'apps')
    end

    def keep_max_time
      15
    end
  end
end
