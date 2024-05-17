# frozen_string_literal: true

class App < ApplicationRecord
  default_scope { order(id: :asc) }

  has_and_belongs_to_many :users
  has_many :collaborators, dependent: :destroy
  has_many :schemes, dependent: :destroy
  has_many :debug_files, dependent: :destroy

  scope :all_names, -> { all.map { |c| [c.name, c.id] } }
  scope :has_debug_files, -> { joins(:debug_files).distinct }

  validates :name, presence: true

  after_destroy :delete_app_recently_releases_cache

  def channel_ids
    return unless schcmes_ids = schemes.select(:id).map(&:id)
    return unless channel_ids = Channel.select(:id).where(scheme: schcmes_ids).map(&:id)

    channel_ids
  end

  def recently_release
    Rails.cache.fetch(recently_release_cache_key, expires_in: 5.minutes) do
      return unless channel_ids
      return unless release = Release.where(channel: channel_ids).last

      release
    end
  end

  def total_schemes
    schemes.size
  end

  def total_channels
    schemes.all.sum { |s| s.channels.size }
  end

  def total_releases
    schemes.all.sum do |scheme|
      scheme.channels.all.sum do |channel|
        channel.releases.size
      end
    end
  end

  def total_debug_files
    debug_files.count
  end

  def android_debug_files
    debug_files.where(device_type: 'Android')
  end

  def ios_debug_files
    debug_files.where(device_type: 'iOS')
  end

  # Fetch all bundle id of iOS app
  def bundle_ids
    all_idenfiters(device_type: 'iOS')[:ios]
  end

  # Fetch all bundle id of iOS app
  def package_names
    all_idenfiters(device_type: 'Android')[:android]
  end

  def all_idenfiters(device_type: nil)
    schemes.all.each_with_object({}) do |scheme, obj|
      channels = scheme.channels
      channels = device_type ? channels.where(device_type: device_type) : channels.all
      channels.each do |channel|
        device_type = channel.device_type.to_sym
        obj[device_type] ||= []
        channel.releases.select(:bundle_id).distinct.each do |release|
          next if obj[device_type].include?(release.bundle_id)

          obj[device_type] << release.bundle_id
        end
      end
    end
  end

  def collaborator_user_ids
    collaborators.select(:user_id).map(&:user_id)
  end

  private

  def recently_release_cache_key
    @recently_release_cache_key ||= "app_#{id}_recently_release"
  end

  def delete_app_recently_releases_cache
    Rails.cache.delete(recently_release_cache_key)
  end
end
