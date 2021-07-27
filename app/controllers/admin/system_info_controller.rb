# frozen_string_literal: true

class Admin::SystemInfoController < ApplicationController
  VERSION_CHECK_URL = 'https://api.github.com/repos/tryzealot/zealot/releases/latest'

  EXCLUDED_MOUNT_OPTIONS = [
    'nobrowse',
    'read-only',
    'ro'
  ]

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
  ]

  # GET /admin/system_info
  def index
    @title = '系统信息'
    @booted_at = Rails.application.config.booted_at
    @current_version = Setting.version

    set_cpus
    set_memory
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
    @memory = Vmstat.memory
  rescue
    @memory = nil
  end

  def set_env
    @env = ENV.each_with_object({}) do |(key, value), obj|
      obj[key] = value
    end.sort
  end

  def set_disks
    mounts = ::Sys::Filesystem.mounts
    @disks = mounts.each_with_object([]) do |mount, obj|
      mount_options = mount.options.split(',')

      next if (EXCLUDED_MOUNT_OPTIONS & mount_options).any?
      next if (EXCLUDED_MOUNT_TYPES & [mount.mount_type]).any?

      begin
        disk = Sys::Filesystem.stat(mount.mount_point)
        next if obj.any? { |i| i[:mount_path] == disk.path }

        obj.push(
          bytes_total: disk.bytes_total,
          bytes_used: disk.bytes_used,
          disk_name: mount.name,
          mount_path: disk.path
        )
      rescue Sys::Filesystem::Error
        next
      end
    end
  end
end
