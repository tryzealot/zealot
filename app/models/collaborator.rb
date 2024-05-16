# frozen_string_literal: true

class Collaborator < ApplicationRecord
  self.table_name = "apps_users"
  self.primary_key = %i[user_id app_id]

  belongs_to :user
  belongs_to :app

  enum role: %i[user developer admin]

  validates :role, presence: true, exclusion: { in: Collaborator.roles.values }
end
