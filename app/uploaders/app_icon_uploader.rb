# frozen_string_literal: true

class AppIconUploader < ApplicationUploader
  include CarrierWave::MiniMagick

  force_extension :png
  process :convert_to_png

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/icons"
  end

  def content_type_allowlist
    /image\//
  end

  def extension_allowlist
    %i(png webp jpeg jpg bmp)
  end

  def convert_to_png
    return unless not_png?

    convert(:png)
  end

  def not_png?
    return false if file.nil?

    File.extname(file.path).casecmp('.png').nonzero?
  end
end
