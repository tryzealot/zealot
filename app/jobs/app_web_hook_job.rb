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

    send_request
  end
  private

  def send_request
    r = HTTP.headers(content_type: 'application/json')
            .post(@web_hook.url, json: commom_params)
    logger.info(log_message('trigger successfully')) if r.code == 200
  rescue HTTP::Error => e
    logger.error(log_message("trigger fail: #{e}"))
  end

  def commom_params
    {
      text: "[#{@channel.app_name}](#{app_url}) - [##{@release.version}](#{release_url}) 发布于#{@release.created_at}",
      attachments: [
        {
          title: description,
          text: @release.changelog_list,
          images: [
            {
              url: "#{app_url}/#{@release.version}/qrcode"
            }
          ]
        }
      ]
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
