# frozen_string_literal: true

class AppIconUploader < ApplicationUploader
  process convert_webp_to_png: [{ quality: 80, method: 5 }], if: :webp?

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/icons"
  end

  def extension_allowlist
    %i(png webp jpeg jpg)
  end

  private

  def convert_webp_to_png(options = {})
    png_path = "#{path}.png"
    WebP.decode(path, png_path)

    @filename = png_path.split('/').pop
    @file = CarrierWave::SanitizedFile.new(
      tempfile: png_path,
      filename: png_path,
      content_type: 'image/png'
    )
  end

  def webp?(file)
    File.extname(file.path) == '.webp'
  end
end
