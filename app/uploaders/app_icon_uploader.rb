# frozen_string_literal: true

class AppIconUploader < ApplicationUploader
  include CarrierWave::MiniMagick

  process convert: :png, if: :not_png?

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/icons"
  end

  # @param [ActionDispatch::Http::UploadedFile] file
  def filename
    return super unless not_png?(file)

    filename = File.basename(file.path)
    "#{filename}.png"
  end

  def content_type_allowlist
    /image\//
  end

  def extension_allowlist
    %i(png webp jpeg jpg bmp)
  end

  # @param [ActionDispatch::Http::UploadedFile] file
  def not_png?(file)
    return false if file.nil?

    File.extname(file.path) != '.png'
  end
end
