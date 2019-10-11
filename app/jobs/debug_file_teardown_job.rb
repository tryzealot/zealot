# frozen_string_literal: true
require 'app-info'

class DebugFileTeardownJob < ApplicationJob
  queue_as :default

  def perform(debug_file)
    parser = AppInfo.parse debug_file.file.file.file
  end
end
