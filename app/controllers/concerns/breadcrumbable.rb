# frozen_string_literal: true

module Breadcrumbable
  extend ActiveSupport::Concern

  Breadcrumb = Struct.new(:label, :path, keyword_init: true)

  # Builds an app -> scheme -> channel trail from whatever the action loaded.
  # `url` is any object exposing the path helpers (a controller or a view
  # context), which lets both the explicit controller override and the
  # automatic view-side helper share one implementation.
  def self.build(app: nil, scheme: nil, channel: nil, url: Rails.application.routes.url_helpers)
    scheme ||= channel&.scheme
    app ||= scheme&.app || channel&.scheme&.app

    # Unsaved records (apps#new, channels#new) have no id/slug and cannot build a path.
    app = nil unless app&.persisted?
    return [] unless app

    scheme = nil unless scheme&.persisted?
    channel = nil unless channel&.persisted?

    trail = [Breadcrumb.new(label: app.name, path: url.app_path(app))]

    if channel
      trail << Breadcrumb.new(label: channel.channel_name, path: url.channel_path(channel))
    elsif scheme
      trail << Breadcrumb.new(label: scheme.name, path: url.app_scheme_path(app, scheme))
    end

    trail
  end

  private

  # Explicit override: set the trail by hand when the automatic derivation is
  # not enough (custom labels, extra levels, ...).
  def set_app_breadcrumbs(app: nil, scheme: nil, channel: nil)
    @breadcrumbs = build_breadcrumbs(app:, scheme:, channel:)
  end

  def build_breadcrumbs(app: nil, scheme: nil, channel: nil)
    Breadcrumbable.build(app:, scheme:, channel:, url: self)
  end
end
