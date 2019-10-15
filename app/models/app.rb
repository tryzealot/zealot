# frozen_string_literal: true

class App < ApplicationRecord
  belongs_to :user
  has_many :schemes, dependent: :destroy
  has_many :debug_files, dependent: :destroy
  accepts_nested_attributes_for :schemes

  validates :name, presence: true

  def self.avaiable_debug_files
    App.joins(:debug_files).distinct #.order('debug_files.id DESC')
  end

  def recently_release
    return unless scheme = schemes.take
    return unless channel = scheme.channels.take
    return unless release = channel.releases.take

    release
  end
end
