require 'yaml'

module Backup
  class App
    include Backup::Manager::Config

    def dump
      prepare

      puts 'Dumping Uploaded apps ... '
    end

    protected

    def prepare
      FileUtils.rm_rf(app_store_path)
      # Fail if somebody raced to create backup_repos_path before us
      FileUtils.mkdir_p(app_store_path, mode: 0700)
    end
  end
end