# frozen_string_literal: true

class CleanOldReleasesJob < ApplicationJob
  queue_as :schedule

  def perform
    channels = Channel.all
    channels.each do |channel|
      logger.debug("Checking channel #{channel.id}")
      clean_old_releases(channel)
    end
  end

  def clean_old_releases(channel)
    versions = channel.release_versions
    return if versions.blank?

    latest_version = versions.max { |a,b| compare_version(a, b) }
    previous_versions = versions.delete_if { |v| v == latest_version }
    previous_versions.each do |value|
      clean_previouse_build_version(channel, value)
    end
  end

  def clean_previouse_build_version(channel, release_version)
    releases = channel.releases.where(release_version: release_version)
    return if releases.size <= 1

    versions = releases.map(&:version)
    latest_version = versions.max { |a,b| compare_version(a, b) }
    logger.info("Delete channel [#{channel.id} - #{channel.app_name}] has versions: #{versions}
                and latest verison is #{latest_version}")

    remove_releases(channel, releases, latest_version)
  end

  def remove_releases(channel, releases, latest_version)
    releases.each do |release|
      next if release.version == latest_version

      logger.info("Deleting release version #{release.version} on channel [#{channel.id}]")
      release.destroy
    end
  end

  def compare_version(a, b)
    Gem::Version.new(a) <=> Gem::Version.new(b)
  rescue ArgumentError => e
    # Note: 处理版本号是 android-1.2.3 类似非标版本号的异常，如有发现就放最后面
    # 后续如果有人反馈问题多了再说，看到本注释的请告知遵守版本号标准
    e.message.include?(a) ? 1 : -1
  end
end
