# frozen_string_literal: true

class App < ApplicationRecord
  scope :avaiable_debug_files, -> { joins(:debug_files).distinct }

  has_and_belongs_to_many :users
  has_many :schemes, dependent: :destroy
  has_many :debug_files, dependent: :destroy

  accepts_nested_attributes_for :schemes

  validates :name, presence: true

  def recently_release
    return unless scheme = schemes.take
    return unless channel = scheme.channels.take
    return unless release = channel.releases.last

    release
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
end
