# frozen_string_literal: true

class ApplicationUploader < CarrierWave::Uploader::Base
  storage :file
  after :remove, :delete_empty_upstream_dirs

  def base_store_dir
    'uploads'
  end

  def size
    @size = file&.size
  end

  def checksum
    chunk = model.send(mounted_as)
    @checksum ||= Digest::MD5.hexdigest(chunk.read.to_s)
  end

  protected

  # Copy from https://github.com/carrierwaveuploader/carrierwave/wiki/how-to:-make-a-fast-lookup-able-storage-directory-structure
  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir, root)
    Dir.delete(path) # fails if path not empty dir

    path = ::File.expand_path(base_store_dir, root)
    Dir.delete(path) # fails if path not empty dir
  rescue SystemCallError
    true # nothing, the dir is not empty
  end
end
