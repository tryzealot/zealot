# frozen_string_literal: true

class DebugFileUploader < ApplicationUploader
  def store_dir
    "#{base_store_dir}/debug_files/a#{model.app.id}/d#{model.id}"
  end

  def extension_white_list
    %w[zip]
  end
end
