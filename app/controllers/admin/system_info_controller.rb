# frozen_string_literal: true

require 'setting'

class Admin::SystemInfoController < ApplicationController
  EXCLUDED_MOUNT_OPTIONS = [
    'nobrowse',
    'read-only',
    'ro'
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

  HIDDEN_ENV_VALUES = [
    'token',
    'key',
    'password',
    'api_key',
    'client_key',
    'secret'
  ].freeze

  EXCLUDED_ENV_KEYS = [
    'SHELL',
    'TERM',
    'USER',
    'EDITOR',
    'PWD',
    'PATH',
    'LANG',
    'HOME',
    'GEM_HOME',
    '_'
  ].freeze

  # GET /admin/system_info
  def index
    @title = '系统信息'

    @cpus = Vmstat.cpu rescue nil
    @memory = Vmstat.memory rescue nil
    @booted_at = Rails.application.config.booted_at
    mounts = ::Sys::Filesystem.mounts

    @disks = mounts.each_with_object([]) do |mount, obj|
      mount_options = mount.options.split(',')

      next if (EXCLUDED_MOUNT_OPTIONS & mount_options).any?
      next if (EXCLUDED_MOUNT_TYPES & [mount.mount_type]).any?

      begin
        disk = Sys::Filesystem.stat(mount.mount_point)
        obj.push(
          bytes_total: disk.bytes_total,
          bytes_used: disk.bytes_used,
          disk_name: mount.name,
          mount_path: disk.path
        )
      rescue Sys::Filesystem::Error
        # do nothing
      end
    end

    @env = ENV.each_with_object({}) do |(key, value), obj|
<<<<<<< HEAD
=======
      next unless EXCLUDED_ENV_KEYS.select { |k| key == k }.empty?

>>>>>>> c1dd834b... feat: 添加系统信息页面
      obj[key] = if HIDDEN_ENV_VALUES.select { |k| key.downcase.include?(k) }.empty?
                   value
                 else
                   '*' * 10
                 end
    end
  end
end
