# frozen_string_literal: true

class AppFileUploader < ApplicationUploader
  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/binary"
  end

  def extension_white_list
    %w[ipa apk].freeze
  end
end
