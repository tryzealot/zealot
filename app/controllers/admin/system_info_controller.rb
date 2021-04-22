# frozen_string_literal: true

class Admin::SystemInfoController < ApplicationController
  VERSION_CHECK_URL = 'https://api.github.com/repos/tryzealot/zealot/releases/latest'

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
    @title = t('menu.system_info')
    @booted_at = Rails.application.config.booted_at
    @current_version = Setting.version

    set_cpus
    set_memory
    set_diskspace
    set_disks
    set_env
  end

  private

  def set_cpus
    @cpus = Vmstat.cpu
  rescue
    @cpus = nil
  end

  def set_memory
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

  def set_env
    @env = ENV.each_with_object({}) do |(key, value), obj|
      obj[key] = secure_key?(key) ? filtered_token(value) : value
    end.sort
  end

  def set_diskspace
    disk = Sys::Filesystem.stat(Rails.root)
    percent = percent(disk.bytes_used, disk.bytes_total)
    @diskspace = {
      used: disk.bytes_used,
      total: disk.bytes_total,
      percent: percent,
      color: progress_color(percent)
    }
  rescue
    @diskspace = nil
  end

  def set_disks
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
