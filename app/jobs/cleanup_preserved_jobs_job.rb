# frozen_string_literal: true

class CleanupPreservedJobsJob < ApplicationJob
  queue_as :schedule

  def perform(older_than: 14.days)
    GoodJob.cleanup_preserved_jobs(older_than: older_than)
  end
end
