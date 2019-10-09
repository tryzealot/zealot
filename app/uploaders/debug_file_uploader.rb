class DebugFileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/debug_files/apps/a#{model.app.id}/"
  end

  def size
    @size = file.size
  end

  def extension_white_list
    %w[zip]
  end

  def checksum
    chunk = model.send(mounted_as)
    @checksum ||= Digest::MD5.hexdigest(chunk.read.to_s)
  end

  def filename
    @name ||= "#{checksum}#{File.extname(super)}" if super
  end
end
