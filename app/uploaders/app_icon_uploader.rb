# frozen_string_literal: true

class AppIconUploader < ApplicationUploader
  include CarrierWave::MiniMagick

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/icons"
  end

  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))

  #   "/media/images/touch-icon.png"
  # end

  version :thumb do
    process resize_to_fit: [30, 30]
  end

  version :medium do
    process resize_to_fit: [80, 80]
  end

  version :large do
    process resize_to_fit: [120, 120]
  end

  def extension_allowlist
    [:png]
  end
end
