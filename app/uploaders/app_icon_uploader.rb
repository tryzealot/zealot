# frozen_string_literal: true

class AppIconUploader < ApplicationUploader
  include CarrierWave::MiniMagick

  process :convert_to_png_if_image

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/icons"
  end

  def content_type_allowlist
    /image\//
  end

  def extension_allowlist
    %i(png webp jpeg jpg bmp)
  end

  def convert_to_png_if_image
    return if file.nil?
    return if File.extname(file.path) != '.png'
    
    self.class.process convert: :png
  end
end
