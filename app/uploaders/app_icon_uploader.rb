class AppIconUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/apps/a#{model.app.id}/r#{model.id}/icons"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
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

  def extension_white_list
    [:png]
  end

  def checksum
    chunk = model.send(mounted_as)
    @checksum ||= Digest::MD5.hexdigest(chunk.read.to_s)
  end

  def filename
    @name ||= "#{checksum}#{File.extname(super)}" if super
  end
end
