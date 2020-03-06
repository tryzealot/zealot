# frozen_string_literal: true

class CleanOldReleasesJob < ApplicationJob
  queue_as :schedule

  def perform
    channels = Channel.all
    channels.each do |channel|
      logger.info("channel #{channel.id}")
      clean_old_releases(channel)
    end
  end

  def clean_old_releases(channel)
    versions = channel.release_versions
    return if versions.empty?

    latest_version = versions.max
    previous_versions = versions.delete_if { |v| v == latest_version }
    previous_versions.each do |value|
      clean_previouse_build_version(channel, value)
    end
  end

  def clean_previouse_build_version(channel, release_version)
    releases = channel.releases.where(release_version: release_version)
    return if releases.size <= 1

    versions = releases.map(&:version)
    latest_version = versions.max
    logger.info("Delete channel [#{channel.id}] has versions: #{versions} and latest verison is #{latest_version}")

    remove_releases(channel, releases, latest_version)
  end

  def remove_releases(channel, releases, latest_version)
    releases.each do |release|
      next if release.version == latest_version

      logger.info("Deleting release version #{release.version} on channel [#{channel.id}]")
      release.destroy
    end
  end
end
