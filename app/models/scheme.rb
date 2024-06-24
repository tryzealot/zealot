# frozen_string_literal: true

class Scheme < ApplicationRecord
  default_scope { order(id: :asc) }

  belongs_to :app
  has_one :visibility, as: :relationable
  has_many :channels, dependent: :destroy
  accepts_nested_attributes_for :channels

  validates :name, presence: true

  after_destroy :delete_app_recently_releases_cache

  def app_name
    "#{app.name} #{name}"
  end

  def latest_channel
    channels.take
  end

  def total_releases
    channels.size
  end

  private

  def recently_release_cache_key
    @recently_release_cache_key ||= "app_#{app.id}_recently_release"
  end

  def delete_app_recently_releases_cache
    Rails.cache.delete(recently_release_cache_key)
  end
end
