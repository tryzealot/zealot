require 'digest/md5'
require 'open3'

class Admin::LogsController < ApplicationController
  FILENAME = 'zealot.log'
  MAX_LINE_NUMBER = 2000

  def index
    @filename = FILENAME
    @logs = logs
    @number = MAX_LINE_NUMBER
  end

  private

  def logs
    return [] unless File.readable?(log_path)

    cmd_stdout = ''
    cmd_stderr = ''
    cmd_status = nil
    cmd = %W(tail -n #{MAX_LINE_NUMBER} #{log_path})
    Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thr|
      out_reader = Thread.new { stdout.read }
      err_reader = Thread.new { stderr.read }

      stdin.close

      cmd_stdout = out_reader.value
      cmd_stderr = err_reader.value
      cmd_status = wait_thr.value
    end

    content = cmd_stdout.strip
    content = content.gsub(/\[\d+m/, '') if Rails.env.development?
    content.split("\n")
  end

  def log_path
    Rails.root.join('log', FILENAME)
  end
end
