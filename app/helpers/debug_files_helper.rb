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
end
