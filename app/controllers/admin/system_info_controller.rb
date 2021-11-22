# frozen_string_literal: true

class Admin::SystemInfoController < ApplicationController
  VERSION_CHECK_URL = 'https://api.github.com/repos/tryzealot/zealot/releases/latest'

  FILE_PERMISSIONS = {
    app: [
      'log',
      'public/backup',
      'public/uploads',
      'tmp'
    ],
    system: [
      '/tmp'
    ]
  }.freeze

  EXCLUDED_MOUNT_OPTIONS = [
    'nobrowse',
    'read-only',
    'ro',
    'noexec'
  ].freeze

  EXCLUDED_MOUNT_TYPES = [
    'autofs',
    'binfmt_misc',
    'cgroup',
    'debugfs',
    'devfs',
    'devpts',
    'devtmpfs',
    'efivarfs',
    'fuse.gvfsd-fuse',
    'fuseblk',
    'fusectl',
    'hugetlbfs',
    'mqueue',
    'proc',
    'pstore',
    'rpc_pipefs',
    'securityfs',
    'sysfs',
    'tmpfs',
    'tracefs',
    'vfat'
  ].freeze

  # GET /admin/system_info
  def index
    @title = t('system_info.title')

    set_env
    set_gems
    set_server_info
    set_disk_volumes
    set_file_permissions
  end

  private

  def set_file_permissions
    @file_permissions = {
      health: true,
      permissions: []
    }

    FILE_PERMISSIONS.each do |scope, paths|
      paths.each do |path|
        real_path = scope == :system ? path : Rails.root.join(path)
        health = File.writable?(real_path)

        @file_permissions[:health] = false if !health
        @file_permissions[:permissions].push(path: real_path.to_s, health: health)
      end
    end

    @file_permissions
  end

  def set_env
    @env = ENV.each_with_object({}) do |(key, value), obj|
      obj[key] = secure_key?(key) ? filtered_token(value) : value
    end.sort
  end

  def set_gems
    @gems ||= Hash[Gem::Specification.map { |spec| [spec.name, spec.version.to_s] }].sort
  end

  def set_disk_volumes
    @disks = ::Sys::Filesystem.mounts.each_with_object([]) do |mount, obj|
      mount_options = mount.options.split(',').map(&:strip)
      next if (EXCLUDED_MOUNT_OPTIONS & mount_options).any?
      next if (EXCLUDED_MOUNT_TYPES & [mount.mount_type]).any?

      begin
        disk = Sys::Filesystem.stat(mount.mount_point)
        next if obj.any? { |i| i[:mount_path] == disk.path }

        percent = percent(disk.bytes_used, disk.bytes_total)
        obj.push(
          bytes_total: disk.bytes_total,
          bytes_used: disk.bytes_used,
          mount_path: disk.path,
          percent: percent,
          color: progress_color(percent)
        )
      rescue Sys::Filesystem::Error
        next
      end
    end
  end

  def set_server_info
    require 'etc'

    @server = {
      os_info: Etc.uname.values.join(' '),
      ruby_version: RUBY_DESCRIPTION,
      zealot_version: Setting.version,
      zealot_vcs_ref: Setting.vcs_ref,
      build_date: Setting.build_date,
      cpu: cpu&.length,
      memory: memory,
      diskspace: diskspace,
      booted_at: Rails.application.config.booted_at
    }
  end

  def cpu
    @cpu ||= Vmstat.cpu
  rescue
    @cpu = nil
  end

  def memory
    return @memory if @memory

    memory = Vmstat.memory
    percent = percent(memory.active_bytes, memory.total_bytes)
    @memory = {
      used: memory.active_bytes,
      total: memory.total_bytes,
      percent: percent,
      color: progress_color(percent)
    }
  rescue
    @memory = nil
  end

  def diskspace
    return @diskspace if @diskspace

    disk = Sys::Filesystem.stat(Rails.root)
    percent = percent(disk.bytes_used, disk.bytes_total)
    @diskspace ||= {
      used: disk.bytes_used,
      total: disk.bytes_total,
      percent: percent,
      color: progress_color(percent)
    }
  rescue
    @diskspace = nil
  end

  def secure_key?(key)
    Rails.application
         .config
         .filter_parameters
         .select { |p| key.downcase.include?(p.to_s) }
         .size
         .positive?
  end

  def filtered_token(chars)
    chars = chars.to_s
    return '*' * chars.size if chars.size < 4

    average = chars.size / 4
    prefix = chars[0..average - 1]
    hidden = '*' * (average * 2)
    suffix = chars[(prefix.size + average * 2)..-1]
    "#{prefix}#{hidden}#{suffix}"
  end

  def percent(value, n)
    value.to_f / n.to_f * 100.0
  end

  def progress_color(percent)
    case percent.to_i
    when 0..60
      'bg-success'
    when 61..80
      'bg-warning'
    else
      'bg-danger'
    end
  end
end
