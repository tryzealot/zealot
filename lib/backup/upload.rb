require 'yaml'

module Backup
  class Upload
    include Backup::Manager::Config

    def dump
      prepare
      puts 'Dumping Uploaded apps ... '
      FileUtils.cp_r(app_store_path, app_backup_path)
    end

    protected

    def prepare
      FileUtils.rm_rf(app_backup_path)
      # Fail if somebody raced to create backup_repos_path before us
      FileUtils.mkdir_p(app_backup_path, mode: 0700)
    end
  end
end