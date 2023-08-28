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

      exit_message = []
      success = [compress_pid, dump_pid].all? do |pid|
        _, exitstatus = Process.waitpid2(pid)
        prefix_message = compress_pid == pid ? 'compress' : 'dump'
        message = "#{prefix_message} #{exitstatus.to_s}"
        exit_message << message
        logger.debug message
        exitstatus.success?
      end

      unless success
        raise Zealot::Backup::DumpDatabaseError, exit_message.join(', ')
      end

      success
    end

    def restore
      decompress_rd, decompress_wr = IO.pipe
      decompress_pid = spawn(*%w(gzip -cd), out: decompress_wr, in: db_file_name)
      decompress_wr.close

      restore_pid =
        case config['adapter']
        when 'postgresql'
          logger.debug "Restoring PostgreSQL database #{config['database']} ... "
          pg_env
          spawn('psql', config['database'], in: decompress_rd)
        end
      decompress_rd.close

      exit_message = []
      success = [decompress_pid, restore_pid].all? do |pid|
        _, exitstatus = Process.waitpid2(pid)
        prefix_message = decompress_pid == pid ? 'decompress' : 'restore'
        message = "#{prefix_message} #{exitstatus.to_s}"
        exit_message << message
        logger.debug message
        exitstatus.success?
      end

      unless success
        raise Zealot::Backup::RestoreDatabaseError, exit_message.join(', ')
      end

      success
    end

    private

    def pg_env
      # Store database data into env
      args = {
        'username'        => 'PGUSER',
        'host'            => 'PGHOST',
        'port'            => 'PGPORT',
        'password'        => 'PGPASSWORD',
        # SSL
        'sslmode'         => 'PGSSLMODE',
        'sslkey'          => 'PGSSLKEY',
        'sslcert'         => 'PGSSLCERT',
        'sslrootcert'     => 'PGSSLROOTCERT',
        'sslcrl'          => 'PGSSLCRL',
        'sslcompression'  => 'PGSSLCOMPRESSION'
      }
      args.each { |opt, arg| ENV[arg] = config[opt].to_s if config[opt] }
    end

    def config
      @config ||= -> {
        config = ERB.new(File.read(Rails.root.join('config', 'database.yml'))).result()
        if YAML.respond_to?(:unsafe_load)
          YAML.unsafe_load(config)
        else
          YAML.load(config)
        end[Rails.env]
      }.call
    end

    def db_file_name
      @db_file_name ||= File.join(backup_path, FILENAME)
    end
  end
end
