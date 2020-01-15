# frozen_string_literal: true

class ApplicationUploader < CarrierWave::Uploader::Base
  storage :file

  def size
    @size = file&.size
  end

  def checksum
    chunk = model.send(mounted_as)
    @checksum ||= Digest::MD5.hexdigest(chunk.read.to_s)
  end

  def filename
    @name ||= "#{checksum}#{File.extname(super)}" if super
  end
end
