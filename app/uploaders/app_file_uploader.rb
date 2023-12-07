# frozen_string_literal: true

class AppFileUploader < ApplicationUploader
  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/binary"
  end
end
