# frozen_string_literal: true

module DebugFilesHelper
  def ios_debug_file?(debug_file)
    debug_file.device_type.downcase.to_sym == :ios
  end

  def debug_file_type(debug_file)
    case debug_file.device_type.downcase.to_sym
    when :ios
      'dSYM'
    when :android
      'Proguard'
    end
  end

  # "1.2.3 (456)" once parsed, "#12" while the upload is still being parsed.
  def debug_file_version(debug_file)
    return "##{debug_file.id}" if debug_file.processing?

    version = [debug_file.release_version, debug_file.build_version.presence&.then { |build| "(#{build})" }]
      .compact_blank
      .join(' ')

    version.presence || "##{debug_file.id}"
  end
end
