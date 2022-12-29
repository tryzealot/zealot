# frozen_string_literal: true

require 'digest/md5'
require 'open3'

class Admin::LogsController < ApplicationController
  before_action :set_log, only: :retrive

  FILENAME = Rails.env.development? ? 'development.log' : 'zealot.log'
  MAX_LINE_NUMBER = 500

  def index
    @filename = FILENAME
    @interval = params[:interval] || 1000
  end

  def retrive
    render plain: @logs
  end

  private

  def set_log
    @max_line = params[:number] || MAX_LINE_NUMBER
    @logs = logs(@max_line)
  end

  def logs(line)
    return '' unless File.readable?(log_path)

    cmd_stdout = ''
    cmd_stderr = ''
    cmd_status = nil
    cmd = %W(tail -n #{line} #{log_path})
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
    content
  end

  def log_path
    Rails.root.join('log', FILENAME)
  end
end
