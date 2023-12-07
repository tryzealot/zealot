# frozen_string_literal: true

class AppleTeam < ApplicationRecord
  belongs_to :key, class_name: 'AppleKey', foreign_key: 'apple_key_id'

  scope :all_names, -> { all.map { |c| ["#{c.display_name} - #{c.team_id}", c.apple_key_id] } }

  validates :apple_key_id, :team_id, :name, presence: true
  before_save :generate_display_name

  def full_name
    return display_name if display_name == name

    "#{display_name} (#{name})"
  end

  private

  def generate_display_name
    self.display_name = name if display_name.blank?
  end
end
