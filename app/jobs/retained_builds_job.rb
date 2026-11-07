# frozen_string_literal: true

class RetainedBuildsJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  queue_as :schedule

  good_job_concurrency_rule(
    label: -> { "retained_builds_channel_#{arguments.first.id}" },
    apply_label: true,
    total_limit: 1
  )

  def perform(channel)
    retained_builds = channel.scheme.retained_builds
    return if retained_builds <= 0
    return if channel.releases.count <= retained_builds

    offset_release = channel.releases.select(:id).limit(1).offset(retained_builds).order(id: :desc).take
    return if offset_release.blank?

    channel.releases.destroy_by('id <= ?', offset_release.id)
  end
end
