class AppWebHookJob < ActiveJob::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper
  include ActiveSupport::NumberHelper

  queue_as :default

  def perform(event, web_hook)
    @web_hook = web_hook
    @app = @web_hook.app
    @release = @app.releases.last

    logger.info(log_message("trigger event: #{event}"))
    logger.info(log_message("trigger url: #{@web_hook.url}"))

    detect_service(web_hook)
  end

  def detect_service(web_hook)
    case web_hook.url
    when /bearychat/i
      request_bearychat
    end
  end

  private

  def log_message(message)
    "[App] #{@app.id} #{message}"
  end

  def request_url
    r = RestClient.get @web_hook.url
    logger.info(log_message('trigger successfully')) if r.code == 200
  rescue RestClient::BadRequest => e
    logger.error(log_message("trigger fail: #{e}"))
  end

  def request_bearychat
    r = RestClient.post @web_hook.url, { payload: JSON.dump(request_bearychat_params) }, content_type: :json
    logger.info(log_message('trigger successfully')) if r.code == 200
  rescue RestClient::BadRequest => e
    logger.error(log_message("trigger fail: #{e}"))
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
      action: 'release',
      slug: @app.slug,
      release_id: @release.version
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

  def request_bearychat_params
    {
      text: "[#{@app.name}](#{app_url}) - [##{@release.version}](#{release_url}) 发布于#{time_ago_in_words(@release.created_at)}",
      attachments: [
        {
          title: description,
          text: @release.changelog.to_s,
          color: '#FFA500',
          images: [
            {
              url: "#{app_url}/#{@release.version}/qrcode"
            }
          ]
        }
      ]
    }
  end
end
