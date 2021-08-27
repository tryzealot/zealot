# frozen_string_literal: true

class AppFileUploader < ApplicationUploader
  process :validate_app_type

  SUPPORT_APP = %i[apk ipa macos]

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/binary"
  end

  def extension_allowlist
    %w[ipa apk zip]
  end

  private

  def validate_app_type
    return if SUPPORT_APP.include?(AppInfo.file_type(file.path))

    raise CarrierWave::InvalidParameter, "无法正常解析应用的类型，目前仅支持 iOS、Android 和使用 Zip 压缩的 macOS App"
  end
end
