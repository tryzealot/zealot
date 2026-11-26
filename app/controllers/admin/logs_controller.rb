# frozen_string_literal: true

require 'digest/md5'
require 'open3'

class Admin::LogsController < ApplicationController
  DEFAULT_FILENAME = Rails.env.development? ? 'development.log' : 'zealot.log'
  MAX_LINE_NUMBER = 500

  def index
    @log_files = available_logs.map { |p| p.basename.to_s }
    @filename = DEFAULT_FILENAME
    @interval = params[:interval] || 2000
  end

  def retrive
    render plain: streaming_file(log_path)
  rescue ActionController::RoutingError
    head :not_found
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
  rescue Errno::ENOENT, Errno::EACCES
    []
  end

  # `params[:file]` reaches this method straight from the query string, so it
  # must never be joined onto a path unchecked: `Pathname#join` happily walks
  # out of `log/`, which turned this action into an arbitrary file read that
  # could lift the Pro engine source or the cached license lease.
  #
  # Two independent gates, because either one alone is bypassable:
  #   1. the name must be a plain entry of `log/` — no separators, no `.`
  #      segments, no leading dot, no `.gz`;
  #   2. the resolved path must still be inside `log/` after symlinks are
  #      followed, which is what `realpath` decides.
  def log_path
    name = params[:file].presence || DEFAULT_FILENAME
    unless available_logs.map { |p| p.basename.to_s }.include?(name)
      raise ActionController::RoutingError, 'log file not found'
    end

    # `realpath` also raises when the entry disappeared between the whitelist
    # scan and here — log rotation does exactly that — so treat it as "not
    # found" rather than letting a race surface as a 500.
    path = begin
      Rails.root.join('log', name).realpath
    rescue Errno::ENOENT, Errno::EACCES
      raise ActionController::RoutingError, 'log file not found'
    end

    log_root = Rails.root.join('log').realpath
    unless path.to_s.start_with?("#{log_root}#{File::SEPARATOR}")
      raise ActionController::RoutingError, 'log file outside log directory'
    end

    path
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
