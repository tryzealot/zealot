# frozen_string_literal: true

class Metadatum < ApplicationRecord
  belongs_to :release
  # alias_method :packet_name, :bundle_id
end
