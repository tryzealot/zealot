# frozen_string_literal: true

class Role < ApplicationRecord
  DEFAULT_ROLE_VALUE = 'user'

  scope :default_role, -> { find_by(value: DEFAULT_ROLE_VALUE) }

  has_and_belongs_to_many :users
  has_many :permissions, dependent: :destroy
end
