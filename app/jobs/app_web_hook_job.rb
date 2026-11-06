# frozen_string_literal: true

class AppWebHookJob < ApplicationJob
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TranslationHelper
  include ActiveSupport::NumberHelper

  queue_as :webhook

  retry_on Faraday::Error, wait: :exponentially_longer, attempts: 3 do |job, error|
    job.send(:handle_webhook_failure, error)
  end

  def perform(event, web_hook, release_or_channel, user_id = nil)
    @event = event
    @web_hook = web_hook
    bind_release_and_channel(release_or_channel)
    @user = User.find_by(id: user_id)

    if @release.blank?
      logger.error(log_message(t('active_job.webhook.failures.empty_release')))
      if @user
        notificate_failure(
          user_id: @user.id,
          type: 'webhook',
          message: t('active_job.webhook.failures.empty_release')
        )
      end
      return
    end

    if @web_hook.url.blank?
      logger.error(log_message(t('active_job.webhook.failures.empty_url')))
      if @user
        notificate_failure(
          user_id: @user.id,
          type: 'webhook',
          message: t('active_job.webhook.failures.empty_url')
        )
      end
      return
    end

    body = WebHookService::PayloadBuilder.build(@web_hook.body, build_context)

    logger.info(log_message("trigger event: #{@event}"))
    logger.info(log_message("trigger url: #{@web_hook.url}"))
    logger.info(log_message("trigger json body: #{body}"))

    send_request(body)
  end

  private

  def bind_release_and_channel(release_or_channel)
    if release_or_channel.is_a?(Release)
      @release = release_or_channel
      @channel = @release.channel
    elsif release_or_channel.is_a?(Channel)
      @channel = release_or_channel
      @release = @channel.releases.last || build_example_release(@channel)
    end
  end

  def send_request(body)
    response = Faraday.post(
      @web_hook.url,
      body,
      { 'Content-Type' => 'application/json' }
    )
    logger.debug(log_message("trigger response body: #{response.body}"))
    if response.success?
      logger.info(log_message('trigger successfully'))
    else
      logger.error(log_message("trigger failed with status: #{response.status}"))
      raise Faraday::Error, "response status: #{response.status}"
    end
  end

  def build_context
    {
      event: @event,
      username: @user&.username || 'guest',
      email: @user&.email,
      title: title,
      name: @release.name,
      app_name: @release.app_name,
      device_type: @channel&.device_type,
      release_version: @release.release_version,
      build_version: @release.build_version,
      bundle_id: @release.bundle_id,
      file_size: @release.file_size,
      changelog: @release.text_changelog,
      release_url: @release.release_url,
      install_url: @release.install_url,
      icon_url: @release.icon_url,
      qrcode_url: @release.qrcode_url,
      uploaded_at: @release.created_at,
      ci_url: @release.ci_url,
      branch: @release.branch,
      source: @release.source,
      release_type: @release.release_type
    }
  end

  def title
    case @event
    when 'upload_events'
      t('teardowns.messages.upload_events', name: @release.app_name, version: @release.release_version)
    when 'download_events'
      t('teardowns.messages.download_events', name: @release.app_name, version: @release.release_version)
    when 'changelog_events'
      t('teardowns.messages.changelog_events', name: @release.app_name, version: @release.release_version)
    else
      t('teardowns.messages.unknown_events', name: @release.app_name, event: @event)
    end
  end

  def log_message(message)
    "[Channel] #{@channel&.id} #{message}"
  end

  def handle_webhook_failure(error)
    _event, web_hook, _release, user_id = arguments
    return if user_id.blank?

    notificate_failure(
      user_id: user_id,
      type: 'webhook',
      message: t('active_job.webhook.failures.send_failed', url: web_hook&.url, error: error.message)
    )
  end

  def build_example_release(channel)
    channel.releases.build(
      name: 'Example App',
      bundle_id: 'im.ews.zealot.example.app',
      release_version: '1.0.0',
      build_version: '5',
      git_commit: '31dbb8497b81e103ecadcab0ca724c3fd87b3ab9'
    )
  end
end
