class AppFileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    path = Rails.env.development? ? "uploads/apps" : "/var/project/mobile/apps"
    "#{path}/#{model.app.id}/ #{model.id}"
  end

  def md5
    chunk = model.send(mounted_as)
    @md5 ||= Digest::MD5.hexdigest(chunk.read.to_s)
  end

  def size
    @size = file.size
  end

  def extension_white_list
    %w(ipa apk)
  end

  def filename
    @name ||= "#{md5}#{File.extname(super)}" if super
  end

end
