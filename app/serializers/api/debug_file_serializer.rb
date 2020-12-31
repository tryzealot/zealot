# frozen_string_literal: true

class Api::DebugFileSerializer < ApplicationSerializer
  # DebugFIle model based
  attributes :id, :app_name, :device_type, :release_version, :build_version, :file_url
  has_many :metadata

  def app_name
    object.app.name
  end
end
