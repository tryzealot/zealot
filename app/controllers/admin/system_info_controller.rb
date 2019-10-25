# frozen_string_literal: true

require 'setting'
require 'http'

class Admin::SystemInfoController < ApplicationController
  VERSION_URL = 'https://api.github.com/repos/icyleaf/zealot/releases/latest'

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
    'secret'
  ].freeze

  # GET /admin/system_info
  def show
    @title = '系统信息'

    collect_enviroments
    collect_disks
    collect_env_vars

    # check_new_version
  end

  private

  def check_new_version
    r = HTTP.get(VERSION_URL)
    @latest_version = r.parse['name']
  end

  def collect_enviroments
    @cpus = Vmstat.cpu rescue nil
    @memory = Vmstat.memory rescue nil
    @booted_at = Rails.application.config.booted_at
  end

  def collect_disks
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
  end

  def collect_env_vars
    @env = ENV.each_with_object({}) do |(key, value), obj|
      obj[key] = if HIDDEN_ENV_VALUES.select { |k| key.downcase.include?(k) }.empty?
                   value
                 else
                   '*' * 10
                 end
    end
  end
end
