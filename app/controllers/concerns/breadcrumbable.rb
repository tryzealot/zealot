# frozen_string_literal: true

module Breadcrumbable
  extend ActiveSupport::Concern

  private

  def set_app_breadcrumbs(app: nil, scheme: nil, channel: nil)
    @breadcrumbs = build_breadcrumbs(app:, scheme:, channel:)
  end

  Breadcrumb = Struct.new(:label, :path, keyword_init: true)

  def build_breadcrumbs(app: nil, scheme: nil, channel: nil)
    scheme ||= channel&.scheme
    app ||= scheme&.app || channel&.scheme&.app

    trail = []

    # return empty trail if no app is provided
    return trail unless app

    if scheme
      trail << Breadcrumb.new(label: scheme.app_name, path: app_path(app))
    else
      trail << Breadcrumb.new(label: app.name, path: app_path(app))
    end

    if channel
      trail << Breadcrumb.new(
        label: channel.name,
        path: channel_path(channel)
      )
    end
    trail
  end
end
