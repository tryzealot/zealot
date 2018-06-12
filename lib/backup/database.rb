require 'yaml'

module Backup
  class Database
    include Backup::Manager::Config

    def dump
      prepare

      compress_rd, compress_wr = IO.pipe
      compress_pid = spawn(*%W(gzip -1 -c), in: compress_rd, out: [db_backup_file_path, 'w', 0600])
      compress_rd.close

      dump_pid = case db_config['adapter']
                  when /^mysql/ then
                    puts "Dumping MySQL database #{db_config['database']} ... "
                    # Workaround warnings from MySQL 5.6 about passwords on cmd line
                    ENV['MYSQL_PWD'] = db_config['password'].to_s if db_config['password']
                    spawn('mysqldump', *mysql_args, db_config['database'], out: compress_wr)
                  else
                    abort 'Unkown database adapter, only support mysql.'
                  end
      compress_wr.close

      success = [compress_pid, dump_pid].all? { |pid| Process.waitpid(pid); $?.success? }
      abort 'Backup failed' unless success

      puts '[DONE]'
    end

    def restore
      decompress_rd, decompress_wr = IO.pipe
      decompress_pid = spawn(*%W(gzip -cd), out: decompress_wr, in: db_backup_file_path)
      decompress_wr.close

      restore_pid = case db_config["adapter"]
      when /^mysql/ then
        print "Restoring MySQL database #{db_config['database']} ... #{db_config['backup_created_at']}"
        # Workaround warnings from MySQL 5.6 about passwords on cmd line
        ENV['MYSQL_PWD'] = db_config['password'].to_s if db_config['password']
        spawn('mysql', *mysql_args, db_config['database'], in: decompress_rd)
      end
      decompress_rd.close

      success = [decompress_pid, restore_pid].all? { |pid| Process.waitpid(pid); $?.success? }
      abort 'Restore failed' unless success

      puts '[DONE]'
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

    def prepare
      FileUtils.mkdir_p(db_backup_path)
      FileUtils.rm_f(db_backup_file_path)
    end
  end
end