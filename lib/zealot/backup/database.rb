# frozen_string_literal: true

# Copyright (c) 2011-present GitLab B.V.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Zealot::Backup
  class Database
    include Zealot::Backup::Helper

    def self.dump(manager)
      new(manager.tmpdir, logger: manager.logger).dump
    end

    def self.restore(backup_path: nil, logger: Rails.logger)
      new(backup_path, logger).restore
    end

    FILENAME = 'database.sql.gz'

    attr_reader :backup_path, :logger

    def initialize(backup_path, logger: Rails.logger)
      @backup_path = backup_path
      @logger = logger
    end

    def dump
      FileUtils.rm_f(db_file_name)

      compress_rd, compress_wr = IO.pipe
      compress_pid = spawn(gzip_cmd, in: compress_rd, out: [db_file_name, 'w', 0600])
      compress_rd.close

      dump_pid =
        case config['adapter']
        when 'postgresql'
          logger.debug "Dumping PostgreSQL database #{config['database']} ... "
          pg_env
          pgsql_args = ["--clean"] # Pass '--clean' to include 'DROP TABLE' statements in the DB dump.
          if Setting.backup[:pg_schema]
            pgsql_args << "-n"
            pgsql_args << Setting.backup[:pg_schema]
          end

          spawn('pg_dump', *pgsql_args, config['database'], out: compress_wr)
        end
      compress_wr.close

      success = [compress_pid, dump_pid].all? do |pid|
        Process.waitpid(pid)
        $?.success?
      end

      raise Zealot::Backup::DatabaseError, 'Backup failed' unless success

      success
    end

    def restore
      decompress_rd, decompress_wr = IO.pipe
      decompress_pid = spawn(*%w(gzip -cd), out: decompress_wr, in: db_file_name)
      decompress_wr.close

      restore_pid =
        case config['adapter']
        when 'postgresql'
          _logger.debug "Restoring PostgreSQL database #{config['database']} ... "
          pg_env
          spawn('psql', config['database'], in: decompress_rd)
        end
      decompress_rd.close

      success = [decompress_pid, restore_pid].all? do |pid|
        Process.waitpid(pid)
        $?.success?
      end

      raise Zealot::Backup::DatabaseError, 'Restore failed' unless success
    end

    private

    def pg_env
      args = {
        'username'        => 'ZEALOT_POSTGRES_USER',
        'host'            => 'ZEALOT_POSTGRES_HOST',
        'port'            => 'ZEALOT_POSTGRES_PORT',
        'password'        => 'ZEALOT_POSTGRES_PASSWORD',
        # SSL
        'sslmode'         => 'ZEALOT_POSTGRES_SSLMODE',
        'sslkey'          => 'ZEALOT_POSTGRES_SSLKEY',
        'sslcert'         => 'ZEALOT_POSTGRES_SSLCERT',
        'sslrootcert'     => 'ZEALOT_POSTGRES_SSLROOTCERT',
        'sslcrl'          => 'ZEALOT_POSTGRES_SSLCRL',
        'sslcompression'  => 'ZEALOT_POSTGRES_SSLCOMPRESSION'
      }
      args.each { |opt, arg| ENV[arg] = config[opt].to_s if config[opt] }
    end

    def config
      return @config if @config

      config = ERB.new(File.read(Rails.root.join('config', 'database.yml'))).result()
      @config = YAML.load(config)[Rails.env]
    end

    def db_file_name
      @db_file_name ||= File.join(backup_path, FILENAME)
    end
  end
end