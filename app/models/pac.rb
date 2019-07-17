require 'resolv'

class Pac < ApplicationRecord
  validates :title, :script, presence: true, on: :web
  validates :host, presence: true, format: { with: Resolv::IPv4::Regex }, on: :api
  validates :port, presence: true, numericality: { only_integer: true }, on: :api
end
