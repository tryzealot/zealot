# frozen_string_literal: true

class AppWebHookJob < ApplicationJob
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper
  include ActiveSupport::NumberHelper

  queue_as :webhook

  def perform(event, web_hook, channel)
    @event = event
    @web_hook = web_hook
    @channel = channel
    @release = @channel.releases.last

    logger.info(log_message("trigger event: #{@event}"))
    logger.info(log_message("trigger url: #{@web_hook.url}"))
    logger.info(log_message("trigger json body: #{json_body}"))

    send_request
  end

  private

  def send_request
    r = HTTP.headers(content_type: 'application/json')
            .post(@web_hook.url, body: json_body)
    logger.debug("trigger response body: #{r.body}")
    logger.info(log_message('trigger successfully')) if r.code == 200
  rescue HTTP::Error => e
    logger.error(log_message("trigger fail: #{e}"))
  end

  def json_body
    # 如果发现自定义钩子就进行组装
    return build_body if @web_hook.body.present?

    # 默认结构体
    WebHooks::PushSerializer.new(@channel).to_json
  end

  def build_body
    ApplicationController.render inline: @web_hook.body,
                                 type: :jb,
                                 assigns: {
                                   event: @event,
                                   title: title,
                                   name: @release.name,
                                   app_name: @release.app_name,
                                   device_type: @channel.device_type,
                                   release_version: @release.release_version,
                                   build_version: @release.build_version,
                                   bundle_id: @release.bundle_id,
                                   changelog: @release.changelog,
                                   file_size: @release.file.size,
                                   release_url: @release.release_url,
                                   install_url: @release.install_url,
                                   icon_url: @release.icon_url(:medium),
                                   qrcode_url: @release.qrcode_url,
                                   uploaded_at: @release.created_at
                                 }
  end

  def title
    case @event
    when 'upload_events'
      "#{@release.app_name} 上传了 #{@release.release_version} 版本"
    when 'download_events'
      "#{@release.app_name} #{@release.release_version} 版本被下载"
    when 'changelog_events'
      "#{@release.app_name} #{@release.release_version} 版本更新了变更日志"
    else
      "#{@release.app_name} 触发了未知事件: #{@event}"
    end
  end

  def log_message(message)
    "[Channel] #{@channel.id} #{message}"
  end
end
