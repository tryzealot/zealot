# frozen_string_literal: true

module DebugFilesHelper
  def debug_file_type(debug_file)
    case debug_file.device_type.downcase.to_sym
    when :ios
      'dSYM'
    when :android
      'Proguard'
    end
  end
end
