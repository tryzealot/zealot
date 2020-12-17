# frozen_string_literal: true

class Metadatum < ApplicationRecord
  belongs_to :release
  belongs_to :user
  # alias_method :packet_name, :bundle_id
end
