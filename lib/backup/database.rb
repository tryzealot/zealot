require 'yaml'

module Backup
  class Database
    include Backup::Manager::Config

    def dump
      prepare
      
      compress_rd, compress_wr = IO.pipe
      compress_pid = spawn(*%W(gzip -1 -c), in: compress_rd, out: [db_file_name, 'w', 0600])
      compress_rd.close

      dump_pid = case db_config['adapter']
      when /^mysql/ then
        puts "Dumping MySQL database #{db_config['database']} ... "
        # Workaround warnings from MySQL 5.6 about passwords on cmd line
        ENV['MYSQL_PWD'] = db_config['password'].to_s if db_config['password']
        spawn('mysqldump', *mysql_args, db_config['database'], out: compress_wr)
      # when 'postgresql' then
      #   puts "Dumping PostgreSQL database #{db_config['database']} ... "
      #   pg_env
      #   pgsql_args = ['--clean'] # Pass '--clean' to include 'DROP TABLE' statements in the DB dump.
      #   if Gitlab.config.backup.pg_schema
      #     pgsql_args << '-n'
      #     pgsql_args << Gitlab.config.backup.pg_schema
      #   end
      #   spawn('pg_dump', *pgsql_args, db_config['database'], out: compress_wr)
      else
        abort 'Unkown database adapter, only support mysql.'
      end
      compress_wr.close

      success = [compress_pid, dump_pid].all? { |pid| Process.waitpid(pid); $?.success? }

      abort 'Backup failed' unless success
    end

    protected

    def mysql_args
      args = {
        'host'      => '--host',
        'port'      => '--port',
        'socket'    => '--socket',
        'username'  => '--user',
        'encoding'  => '--default-character-set'
      }
      args.map { |opt, arg| "#{arg}=#{db_config[opt]}" if db_config[opt] }.compact
    end

    def pg_env
      ENV['PGUSER']     = db_config['username'] if db_config['username']
      ENV['PGHOST']     = db_config['host'] if db_config['host']
      ENV['PGPORT']     = db_config['port'].to_s if db_config['port']
      ENV['PGPASSWORD'] = db_config['password'].to_s if db_config['password']
    end

    def prepare
      FileUtils.mkdir_p(db_store_path)
      FileUtils.rm_f(db_file_name)
    end
  end
end