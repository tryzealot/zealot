# frozen_string_literal: true

class Api::DebugFiles::VersionExistController < Api::BaseController
  before_action :validate_channel_key

  # GET /api/debug_files/version_exist
  def show
    determine_params!

    where_params = channel_params.merge(
      app_id: @channel.app.id,
      device_type: @channel.device_type
    )
    raise ActiveRecord::RecordNotFound, '调试文件版本不存在' unless DebugFile.exists?(where_params)

    render json: DebugFile.find_by(where_params)
  end

  private

  def determine_params!
    return if (channel_params.key?(:release_version) && channel_params.key?(:build_version))

    raise ActionController::ParameterMissing, '缺失 release_version, build_version 参数'
  end

  def channel_params
    params.permit(:app_id, :device_type, :release_version, :build_version)
  end
end
