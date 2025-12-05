# frozen_string_literal: true

module RecentlyReleasesCacheable
  extend ActiveSupport::Concern

  included do
    after_destroy :delete_app_recently_releases_cache
  end

  private

  def delete_app_recently_releases_cache
    Rails.cache.delete(recently_release_cache_key)
  end

  def recently_release_cache_key
    "app_#{recently_release_app_id}_recently_release"
  end

  def recently_release_app_id
    raise NotImplementedError, "#{self.class.name} must implement ##{__method__}"
  end
end
