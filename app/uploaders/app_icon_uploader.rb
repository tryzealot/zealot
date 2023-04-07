# frozen_string_literal: true

class AppIconUploader < ApplicationUploader
  include CarrierWave::MiniMagick

  process convert: :png, if: :not_png?

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/icons"
  end

  def filename
    return super unless file

    "#{file.basename}.png"
  end

  def content_type_allowlist
    /image\//
  end

  def not_png?
    File.extname(file.path) != '.png'
  end
end
