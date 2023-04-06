# frozen_string_literal: true

class AppFileUploader < ApplicationUploader
  # process :validate_app_type

  SUPPORT_APP = %i[apk aab ipa macos]

  def store_dir
    "#{base_store_dir}/apps/a#{model.app.id}/r#{model.id}/binary"
  end

  # def extension_allowlist
  #   %w[ipa apk aab zip]
  # end

  # private

  # def validate_app_type
  #   return if SUPPORT_APP.include?(AppInfo.file_type(file.path))

  #   raise CarrierWave::InvalidParameter, I18n.t('errors.messages.unknown_file_type')
  # end
end
