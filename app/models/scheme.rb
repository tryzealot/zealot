# frozen_string_literal: true

class Scheme < ApplicationRecord
  include RecentlyReleasesCacheable

  default_scope { order(id: :asc) }

  belongs_to :app
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

  def recently_release_app_id
    app.id
  end
end
