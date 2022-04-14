class Admin::LogsController < ApplicationController
  FILENAME = Rails.env.development? ? 'development.log' : 'zealot.log'

  def index
    @title = '系统日志'
    @filename = FILENAME
    @logs = logs
  end

  private

  def logs
    return [] unless File.readable?(log_path)

    require 'open3'

    cmd = %W(tail -n 2000 #{log_path})

    cmd_stdout = ''
    cmd_stderr = ''
    cmd_status = nil
    Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thr|
      out_reader = Thread.new { stdout.read }
      err_reader = Thread.new { stderr.read }

      stdin.close

      cmd_stdout = out_reader.value
      cmd_stderr = err_reader.value
      cmd_status = wait_thr.value
    end

    cmd_stdout.split("\n")
  end

  def log_path
    Rails.root.join('log', FILENAME)
  end
end
