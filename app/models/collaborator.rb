# frozen_string_literal: true

class Collaborator < ApplicationRecord
  self.table_name = "apps_users"
  self.primary_key = %i[user_id app_id]

  belongs_to :user
  belongs_to :app

  enum role: %i[user developer admin]

  validates :owner, inclusion: [ true, false ]
  validates :role, presence: true, exclusion: { in: Collaborator.roles.values }

  validate :one_owner_on_each_app, if: :owner_is_truth?

  private

  def one_owner_on_each_app
    return true unless Collaborator.where(app: app, owner: true).exists?

    errors.add(:owner, :unique)
  end

  def owner_is_truth?
    owner == true
  end
end
