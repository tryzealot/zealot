# frozen_string_literal: true

class App < ApplicationRecord
  belongs_to :user
  has_many :schemes, dependent: :destroy
  accepts_nested_attributes_for :schemes

  validates :name, presence: true
end
