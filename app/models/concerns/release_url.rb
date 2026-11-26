# frozen_string_literal: true

module ReleaseUrl
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  def default_url_options
    opts = super rescue {}
    opts = opts.is_a?(Hash) ? opts : {}
    opts.merge(org_slug: organization_slug_for_url)
  end

  def download_url
    download_release_url(self, org_slug: organization_slug_for_url)
  end

  def install_url
    return download_url unless platform == 'iOS'

    ios_url = channel_release_install_url(channel, self, org_slug: organization_slug_for_url)
    "itms-services://?action=download-manifest&url=#{ios_url}"
  end

  def release_url
    friendly_channel_release_url(channel, self, org_slug: organization_slug_for_url)
  end

  def qrcode_url(**options)
    opts = { org_slug: organization_slug_for_url }.merge(options)
    channel_release_qrcode_url(channel, self, **opts)
  end

  private

  def organization_slug_for_url
    return unless defined?(Zealot::Pro) && app.respond_to?(:organization)

    org = app.organization
    return if org.nil? || org.slug.blank?
    return if org.respond_to?(:default?) && org.default?
    return unless Zealot::Pro.enabled?(:multi_org)

    org.slug
  rescue StandardError
    nil
  end
end
