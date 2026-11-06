# frozen_string_literal: true

class WebHookService
  EVENT_MAPPING = {
    upload: 'upload_events',
    upload_events: 'upload_events',
    download: 'download_events',
    download_events: 'download_events',
    changelog: 'changelog_events',
    changelog_events: 'changelog_events'
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(event, channel:, release: nil, user: nil)
    @event_column = normalize_event(event)
    @channel = channel
    @release = release || channel.releases.last
    @user = user
  end

  def call
    matching_web_hooks.find_each do |web_hook|
      AppWebHookJob.perform_later(@event_column, web_hook, @release, @user&.id)
    end
  end

  private

  def normalize_event(event)
    EVENT_MAPPING[event.to_sym] || event.to_s
  end

  def matching_web_hooks
    @channel.web_hooks.where(@event_column => 1)
  end
end
