# frozen_string_literal: true

require 'digest/md5'
require 'open3'

class Admin::LogsController < ApplicationController
  before_action :set_log, only: :retrive

  DEFAULT_FILENAME = Rails.env.development? ? 'development.log' : 'zealot.log'
  MAX_LINE_NUMBER = 500

  def index
    @log_files = available_logs.map { |p| p.basename.to_s }
    @filename = DEFAULT_FILENAME
    @interval = params[:interval] || 2000
  end

  def retrive
    render plain: streaming_file(log_path)
  end

  private

  def available_logs
    log_dir = Rails.root.join('log')
    Dir.children(log_dir).filter_map do |name|
      next if name.start_with?('.')
      next if name.end_with?('.gz')

      path = log_dir.join(name)
      File.file?(path) && File.readable?(path) ? path : nil
    end.sort_by { |p| -File.mtime(p).to_i }
  end

  def set_log
    @logs = streaming_file(log_path)
  end

  def log_path
    Rails.root.join('log', params[:file] || DEFAULT_FILENAME)
  end

  CHUNK_SIZE = 8192
  def streaming_file(path) 
    return '' unless File.readable?(path)
    return '' if MAX_LINE_NUMBER <= 0

    content = ''
    File.open(path, 'r') do |file|
      size = file.size
      return '' if size.zero?

      pos = size
      chunks = []
      lines_found = 0

      while pos.positive? && lines_found <= MAX_LINE_NUMBER
        read_size = [CHUNK_SIZE, pos].min
        pos -= read_size
        file.seek(pos)
        data = file.read(read_size)
        chunks.unshift(data)
        lines_found += data.count("\n")
      end

      buffer = chunks.join
      content = buffer.split("\n").last(MAX_LINE_NUMBER).join("\n")
    end

    # Remove ANSI color codes in development environment
    content = content.strip.gsub(/\e\[[0-9;]*[A-Za-z]?/, '') if Rails.env.development?
    content
  end
end
