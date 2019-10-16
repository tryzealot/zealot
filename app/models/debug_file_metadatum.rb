class DebugFileMetadatum < ApplicationRecord
  # serialize :data, HashSerializer

  belongs_to :debug_file

  self.inheritance_column = :_type_disabled
end
