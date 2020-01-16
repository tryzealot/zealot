# frozen_string_literal: true

class DebugFileMetadatum < ApplicationRecord
  belongs_to :debug_file

  self.inheritance_column = :_type_disabled
end
