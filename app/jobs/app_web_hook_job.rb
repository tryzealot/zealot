class AppWebHookJob < ApplicationJob
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper
  include ActiveSupport::NumberHelper

  queue_as :default

  def perform(event, web_hook)
    @web_hook = web_hook
    @channel = @web_hook.channel
    @release = @channel.releases.last

    logger.info(log_message("trigger event: #{event}"))
    logger.info(log_message("trigger url: #{@web_hook.url}"))
    logger.info(log_message("trigger json body: #{json_body}"))

    send_request
  end

  private

  def send_request
    r = HTTP.headers(content_type: 'application/json')
            .post(@web_hook.url, body: json_body)
    logger.info(log_message('trigger successfully')) if r.code == 200
    logger.debug("trigger response body: #{r.body}")
  rescue HTTP::Error => e
    logger.error(log_message("trigger fail: #{e}"))
  end

  def json_body
    return format_body unless @web_hook.body.blank?

    WebHooks::PushSerializer.new(@channel).to_json
  end

  def format_body
    ApplicationController.render inline: @web_hook.body,
                                 type: :jb,
                                 assigns: {
                                   name: @release.app_name,
                                   device_type: @channel.device_type,
                                   release_version: @release.release_version,
                                   build_version: @release.build_version,
                                   bundle_id: @release.bundle_id,
                                   changelog: @release.changelog,
                                   file_size: @release.size,
                                   app_url: @release.release_url,
                                   install_url: @release.install_url,
                                   icon_url: @release.icon_url(:medium),
                                   qrcode_url: @release.qrcode_url,
                                   created_at: @release.created_at
                                 }
  end

  def app_url
    url_for(
      host: Rails.application.secrets.domain_name,
      controller: 'apps',
      action: 'show',
      slug: @app.slug
    )
  end

  def release_url
    url_for(
      host: Rails.application.secrets.domain_name,
      controller: 'apps',
      action: 'show',
      slug: @app.slug,
      version: @release.version
    )
  end

  def description
    [
      "平台：#{@app.device_type}",
      "标识：#{@app.identifier}",
      "版本：#{@release.release_version} (#{@release.build_version})",
      "大小：#{number_to_human_size(@release.filesize)}",
      "渠道：#{@release.channel}"
    ].join(' / ')
  end

  def log_message(message)
    "[Channel] #{@channel.id} #{message}"
  end
end
